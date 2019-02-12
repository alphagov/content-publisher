# frozen_string_literal: true

class WithdrawService
  def call(edition, public_explanation, user = nil)
    Document.transaction(requires_new: true) do
      edition.document.lock!
      check_withdrawable(edition)

      return if withdrawn_with_public_explanation?(edition, public_explanation)

      withdrawal = build_withdrawal(edition, public_explanation)

      already_withdrawn = edition.withdrawn?
      edition.assign_status(:withdrawn, user, status_details: withdrawal)
      edition.save!

      TimelineEntry.create_for_status_change(
        entry_type: already_withdrawn ? :withdrawn_updated : :withdrawn,
        status: edition.status,
        details: withdrawal,
      )

      GdsApi.publishing_api_v2.unpublish(
        edition.content_id,
        type: "withdrawal",
        explanation: format_govspeak(public_explanation, edition),
        locale: edition.locale,
      )
    end
  end

private

  def check_withdrawable(edition)
    document = edition.document

    if edition != document.live_edition
      raise "attempted to withdraw an edition other than the live edition"
    end

    if document.current_edition != document.live_edition
      raise "Publishing API does not support unpublishing while there is a draft"
    end
  end

  def withdrawn_with_public_explanation?(edition, public_explanation)
    return false unless edition.withdrawn?

    withdrawal = edition.status.details
    withdrawal.public_explanation == public_explanation
  end

  def build_withdrawal(edition, public_explanation)
    if edition.withdrawn?
      withdrawal = edition.status.details.dup
      withdrawal.tap do |w|
        w.assign_attributes(public_explanation: public_explanation)
      end
    else
      Withdrawal.new(public_explanation: public_explanation,
                     published_status: edition.status,
                     withdrawn_at: Time.current)
    end
  end

  def format_govspeak(text, edition)
    GovspeakDocument.new(text, edition).payload_html
  end
end
