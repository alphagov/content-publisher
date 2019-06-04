# frozen_string_literal: true

class Schedule::SaveDatetimeInteractor
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
      set_scheduled_publishing_datetime
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
    pre_issues = checker.pre_submit_issues.issues

    issues = Requirements::CheckerIssues.new(pre_issues + action_issues)

    context.fail!(issues: issues) if issues.any?

    context.datetime = checker.parsed_datetime
  end

  def schedule_params
    params.require(:schedule).permit(:day, :month, :year, :time)
  end

  def set_scheduled_publishing_datetime
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(scheduled_publishing_datetime: datetime)

    context.fail! unless updater.changed?

    edition.assign_revision(updater.next_revision, user).save!
  end

  def action_issues
    action = params[:schedule][:action] || params[:schedule][:update]

    if action.blank?
      [Requirements::Issue.new(:scheduled_datetime, :action_not_selected)]
    else
      []
    end
  end
end
