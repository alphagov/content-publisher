# frozen_string_literal: true

class Schedule::UpdateInteractor
  include Interactor

  delegate :params,
           :user,
           :edition,
           :issues,
           :publish_time,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      reschedule_to_publish
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])

    unless edition.scheduled?
      raise "Can't reschedule an edition which isn't scheduled"
    end
  end

  def check_for_issues
    checker = Requirements::ScheduleDatetimeChecker.new(schedule_params)
    issues = checker.pre_submit_issues
    context.fail!(issues: issues) if issues.any?

    context.publish_time = checker.parsed_datetime
  end

  def reschedule_to_publish
    scheduling = edition.status.details
    context.fail! if publish_time == scheduling.publish_time

    ScheduleService.new(edition).reschedule(publish_time: publish_time, user: user)
  end

  def schedule_params
    params.require(:schedule).permit(:time, date: %i[day month year])
  end
end
