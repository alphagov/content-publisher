# frozen_string_literal: true

class Schedule::NewInteractor < ApplicationInteractor
  delegate :params,
           :user,
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
    assert_edition_state(edition, &:editable?)

    assert_edition_state(edition, assertion: "has proposed publish time") do
      edition.proposed_publish_time.present?
    end
  end

  def check_for_publish_issues
    issues = Requirements::EditionChecker.new(edition)
                                         .pre_publish_issues(rescue_api_errors: false)

    context.fail!(publish_issues: issues) if issues.any?
  end

  def check_for_schedule_issues
    issues = Requirements::PublishTimeChecker.new(edition.proposed_publish_time)
                                             .issues
    context.fail!(schedule_issues: issues) if issues.any?
  end
end
