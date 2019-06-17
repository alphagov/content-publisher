# frozen_string_literal: true

class Schedule::NewInteractor
  include Interactor

  delegate :params,
           :edition,
           :publish_issues,
           :schedule_issues,
           to: :context

  def call
    find_edition
    check_for_publish_issues
    check_for_schedule_issues
  end

  def find_edition
    context.edition = Edition.find_current(document: params[:document])
  end

  def check_for_publish_issues
    issues = Requirements::EditionChecker.new(edition)
                                         .pre_publish_issues(rescue_api_errors: false)

    context.fail!(publish_issues: issues) if issues.any?
  end

  def check_for_schedule_issues
    issues = Requirements::ScheduleChecker.new(edition.revision).pre_schedule_issues
    context.fail!(schedule_issues: issues) if issues.any?
  end
end
