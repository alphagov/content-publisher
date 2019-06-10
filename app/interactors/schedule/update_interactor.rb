# frozen_string_literal: true

class Schedule::UpdateInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :issues,
           :datetime,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      update_edition
      reschedule_to_publish
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def check_for_issues
    unless edition.scheduled?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Can't reschedule an edition which isn't scheduled"
    end

    checker = Requirements::ScheduleDatetimeChecker.new(schedule_params)
    issues = checker.pre_submit_issues
    context.fail!(issues: issues) if issues.any?

    context.datetime = checker.parsed_datetime
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(scheduled_publishing_datetime: datetime)
    context.fail! unless updater.changed?
    edition.assign_revision(updater.next_revision, user).save!
  end

  def reschedule_to_publish
    ScheduleService.new(edition).reschedule(user: user)
  end

  def schedule_params
    params.require(:schedule).permit(:time, date: %i[day month year])
  end
end
