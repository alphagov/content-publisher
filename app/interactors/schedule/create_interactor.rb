# frozen_string_literal: true

class Schedule::CreateInteractor
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
      schedule_to_publish
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def check_for_issues
    unless edition.editable? && edition.proposed_publish_time.present?
      # FIXME: this shouldn't be an exception but we've not worked out the
      # right response - maybe bad request or a redirect with flash?
      raise "Can't schedule an edition which isn't schedulable"
    end

    if params[:review_status].blank?
      issues = Requirements::CheckerIssues.new([
        Requirements::Issue.new(:schedule_review_status, :not_selected),
      ])
    end

    context.fail!(issues: issues) if issues
  end

  def schedule_to_publish
    reviewed = params[:review_status] == "reviewed"
    ScheduleService.new(edition).schedule(user: user, reviewed: reviewed)
  end
end
