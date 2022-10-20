class Review::SubmitFor2iInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :issues,
           :api_error,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues

      update_status
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:draft?)
  end

  def check_for_issues
    issues = Requirements::Publish::EditionChecker.call(edition)
    context.fail!(issues:) if issues.any?
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end

  def update_status
    AssignEditionStatusService.call(edition, user:, state: :submitted_for_review)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(entry_type: :submitted, status: edition.status)
  end
end
