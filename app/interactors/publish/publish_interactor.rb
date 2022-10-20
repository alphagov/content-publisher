class Publish::PublishInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :issues,
           :publish_failed,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues

      publish_edition
      create_timeline_entry
    end

    send_notifications
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)

    assert_edition_state(edition, assertion: "has no requirements issues") do
      Requirements::Publish::EditionChecker.call(edition).none?
    end
  end

  def check_for_issues
    issues = Requirements::CheckerIssues.new
    issues.create(:review_status, :not_selected) if params[:review_status].blank?
    context.fail!(issues:) if issues.any?
  end

  def with_review?
    params[:review_status] == "reviewed"
  end

  def publish_edition
    PublishDraftEditionService.call(edition, user, with_review: with_review?)
  rescue GdsApi::BaseError
    context.fail!(publish_failed: true)
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(
      entry_type: with_review? ? :published : :published_without_review,
      status: edition.status,
    )
  end

  def send_notifications
    edition.editors.each do |editor|
      PublishMailer.publish_email(editor, edition, edition.status).deliver_later
    end
  end
end
