class ScheduleProposal::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :edition,
           :revision,
           :user,
           :issues,
           :publish_time,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      parse_publish_time
      check_for_issues
      update_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def parse_publish_time
    parser = DatetimeParser.new(issue_prefix: :schedule,
                                date: schedule_params.require(:date),
                                time: schedule_params.require(:time))
    context.publish_time = parser.parse
    context.fail!(issues: parser.issues) if parser.issues.any?
  end

  def check_for_issues
    issues = Requirements::PublishTimeChecker.new.issues(publish_time)
    issues += action_issues if params[:wizard] == "schedule"
    context.fail!(issues: issues) if issues.any?
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(proposed_publish_time: publish_time)

    context.fail! unless updater.changed?

    context.revision = updater.next_revision
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def action_issues
    issues = Requirements::CheckerIssues.new
    issues.create(:schedule_action, :not_selected) if schedule_params[:action].blank?
    issues
  end

  def schedule_params
    params.require(:schedule).permit(:time, :action, date: %i[day month year])
  end
end
