class WithdrawDocumentService
  include Callable

  def initialize(edition, user, public_explanation:)
    @edition = edition
    @public_explanation = public_explanation
    @user = user
  end

  def call
    edition.document.lock!
    check_withdrawable
    withdrawal = build_withdrawal
    update_edition(withdrawal)
    unpublish_edition
  end

private

  attr_reader :edition, :public_explanation, :user

  def unpublish_edition
    GdsApi.publishing_api.unpublish(
      edition.content_id,
      type: "withdrawal",
      explanation: format_govspeak(public_explanation, edition),
      locale: edition.locale,
      unpublished_at: edition.status.details.withdrawn_at,
    )
  end

  def update_edition(withdrawal)
    AssignEditionStatusService.call(edition,
                                    user: user,
                                    state: :withdrawn,
                                    status_details: withdrawal)
    edition.save!
  end

  def check_withdrawable
    document = edition.document

    if edition != document.live_edition
      raise "attempted to withdraw an edition other than the live edition"
    end

    if document.current_edition != document.live_edition
      raise "Publishing API does not support unpublishing while there is a draft"
    end
  end

  def build_withdrawal
    if edition.withdrawn?
      withdrawal = edition.status.details.dup
      withdrawal.tap do |w|
        w.assign_attributes(public_explanation: public_explanation)
      end
    else
      Withdrawal.new(public_explanation: public_explanation,
                     published_status: edition.status,
                     withdrawn_at: Time.zone.now)
    end
  end

  def format_govspeak(text, edition)
    GovspeakDocument.new(text, edition).payload_html
  end
end
