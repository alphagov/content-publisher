class Schedule::CreateInteractor < ApplicationInteractor
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
      schedule_to_publish
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)

    assert_edition_state(edition, assertion: "has proposed publish time") do
      edition.proposed_publish_time.present?
    end

    assert_edition_state(edition, assertion: "has no requirements issues") do
      Requirements::Publish::EditionChecker.call(edition).none?
    end
  end

  def check_for_issues
    issues = Requirements::CheckerIssues.new
    issues.create(:schedule_review_status, :not_selected) if params[:review_status].blank?
    context.fail!(issues:) if issues.any?
  end

  def schedule_to_publish
    scheduling = Scheduling.new(pre_scheduled_status: edition.status,
                                reviewed: params[:review_status] == "reviewed",
                                publish_time: edition.proposed_publish_time)

    SchedulePublishService.call(edition, user, scheduling)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    context.fail!(api_error: true)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(
      entry_type: :scheduled,
      status: edition.status,
      details: edition.status.details,
    )
  end
end
