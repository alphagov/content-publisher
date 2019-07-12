# frozen_string_literal: true

class Schedule::CreateInteractor < ApplicationInteractor
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
    assert_with_edition(edition, &:editable)

    assert_with_edition(edition, assertion: "Edition has proposed publish time") do
      edition.proposed_publish_time.present?
    end

    assert_with_edition(edition, assertion: "Edition has no requirements issues") do
      Requirements::EditionChecker.new(edition).pre_publish_issues(rescue_api_errors: false).any?
    end
  end

  def check_for_issues
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
