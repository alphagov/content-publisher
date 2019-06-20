# frozen_string_literal: true

class Schedule::UpdateInteractor
  include Interactor

  delegate :params,
           :user,
           :edition,
           :revision,
           :issues,
           :publish_time,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      parse_publish_time
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

  def parse_publish_time
    parser = DatetimeParser.new(issue_prefix: :schedule, **schedule_params)
    context.publish_time = parser.parse
    context.fail!(issues: parser.issues) if parser.issues.any?
  end

  def check_for_issues
    checker = Requirements::PublishTimeChecker.new(publish_time)
    issues = checker.issues
    context.fail!(issues: issues) if issues.any?
  end

  def reschedule_to_publish
    scheduling = edition.status.details
    context.fail! if publish_time == scheduling.publish_time

    ScheduleService.new(edition).reschedule(publish_time: publish_time, user: user)
  end

  def schedule_params
    params.require(:schedule).permit(:time, date: %i[day month year])
      .to_h.deep_symbolize_keys
  end
end
