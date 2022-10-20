class Withdraw::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :issues,
           :api_error,
           :already_withdrawn,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      check_previous_withdrawal
      withdraw_edition
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])

    assert_edition_state(edition, assertion: "is published or withdrawn") do
      edition.published? || edition.published_but_needs_2i? || edition.withdrawn?
    end
  end

  def check_for_issues
    issues = Requirements::Form::WithdrawalChecker.call(edition, params[:public_explanation])
    context.fail!(issues:) if issues.any?
  end

  def check_previous_withdrawal
    context.already_withdrawn = edition.withdrawn?
    return unless already_withdrawn

    previous_explanation = edition.status.details.public_explanation
    context.fail! if previous_explanation == params[:public_explanation]
  end

  def withdraw_edition
    WithdrawDocumentService.call(edition,
                                 user,
                                 public_explanation: params[:public_explanation])
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(
      entry_type: already_withdrawn ? :withdrawn_updated : :withdrawn,
      status: edition.status,
      details: edition.status.details,
    )
  end
end
