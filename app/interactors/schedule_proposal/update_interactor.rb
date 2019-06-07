# frozen_string_literal: true

class ScheduleProposal::UpdateInteractor
  include Interactor
  delegate :params,
           :edition,
           :user,
           :issues,
           :datetime,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      update_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def check_for_issues
    unless edition.draft? || edition.submitted_for_review?
      raise "Can't save a scheduling date unless edition is a draft or has been submitted for 2i"
    end

    checker = Requirements::ScheduledDatetimeChecker.new(schedule_params)
    issues = checker.pre_submit_issues.to_a
    issues += action_issues if params[:wizard] == "schedule"

    context.fail!(issues: Requirements::CheckerIssues.new(issues)) if issues.any?
    context.datetime = checker.parsed_datetime
  end

  def schedule_params
    params.require(:schedule).permit(:time, :action, date: %i[day month year])
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(scheduled_publishing_datetime: datetime)

    context.fail! unless updater.changed?

    edition.assign_revision(updater.next_revision, user).save!
  end

  def action_issues
    return [] if schedule_params[:action].present?

    [Requirements::Issue.new(:schedule_action, :not_selected)]
  end

  def scheduled_datetime_already_exists?
    edition.scheduled_publishing_datetime.present?
  end
end
