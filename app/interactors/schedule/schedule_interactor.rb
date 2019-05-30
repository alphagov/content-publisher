# frozen_string_literal: true

class Schedule::ScheduleInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :issues,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      schedule_publishing
      create_scheduling
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def check_for_issues
    unless edition.schedulable?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Can't schedule an edition which isn't schedulable"
    end

    if params[:review_status].blank?
      issues = Requirements::CheckerIssues.new([
        Requirements::Issue.new(:schedule_review, :not_selected),
      ])
    end

    context.fail!(issues: issues) if issues
  end

  def schedule_publishing
    datetime = edition.scheduled_publishing_datetime
    ScheduledPublishingJob.set(wait_until: datetime).perform_later(edition.id)
  end

  def create_scheduling
    reviewed = params[:review_status] == "reviewed"
    ScheduleService.new(edition).schedule(user: user, reviewed: reviewed)
  end
end
