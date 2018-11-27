# frozen_string_literal: true

class PreviewService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def create_preview(args)
    save_changes(args)
    publish_draft(document)
  end

  def try_create_preview(args)
    save_changes(args)
    try_publish_draft(document) unless has_issues?
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
  end

private

  def save_changes(user:, type:)
    create_new_edition(document) if published?(document)

    document.publication_state = "changes_not_sent_to_draft"
    document.last_editor = user if edited?(type)
    document.review_state = "unreviewed" unless in_review?(document)

    Document.transaction do
      document.save!
      TimelineEntry.create!(document: document, user: user, entry_type: type)
    end
  end

  def has_issues?
    Requirements::DocumentChecker.new(document).pre_preview_issues.any?
  end

  def edited?(type)
    %w(updated_content updated_tags).include?(type)
  end

  def in_review?(document)
    document.review_state == "submitted_for_review"
  end

  def published?(document)
    document.publication_state == "sent_to_live"
  end

  def create_new_edition(document)
    document.current_edition_number += 1
    document.change_note = nil
    document.update_type = "major"
  end

  def try_publish_draft(document)
    publish_draft(document)
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    document.update!(publication_state: "changes_not_sent_to_draft")
  end

  def publish_draft(document)
    payload = PublishingApiPayload.new(document).payload
    GdsApi.publishing_api_v2.put_content(document.content_id, payload)
    document.update!(publication_state: "sent_to_draft")
  rescue GdsApi::BaseError
    document.update!(publication_state: "error_sending_to_draft")
    raise
  end
end
