# frozen_string_literal: true

class ScheduleProposal::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :edition,
           :revision,
           :user,
           :issues,
           :publish_time,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      parse_publish_time
      check_for_issues
      update_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def parse_publish_time
    parser = DatetimeParser.new(issue_prefix: :schedule, **schedule_params.slice(:date, :time))
    context.publish_time = parser.parse
    context.fail!(issues: parser.issues) if parser.issues.any?
  end

  def check_for_issues
    checker = Requirements::PublishTimeChecker.new(publish_time)
    issues = checker.issues.to_a
    issues += action_issues if params[:wizard] == "schedule"

    context.fail!(issues: Requirements::CheckerIssues.new(issues)) if issues.any?
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(proposed_publish_time: publish_time)

    context.fail! unless updater.changed?

    context.revision = updater.next_revision
    edition.assign_revision(revision, user).save!
  end

  def action_issues
    return [] if schedule_params[:action].present?

    [Requirements::Issue.new(:schedule_action, :not_selected)]
  end

  def schedule_params
    params.require(:schedule).permit(:time, :action, date: %i[day month year])
      .to_h.deep_symbolize_keys
  end
end
