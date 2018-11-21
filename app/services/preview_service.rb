# frozen_string_literal: true

class PreviewService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def create_preview(user:, type:)
    create_new_edition(document) if published?(document)
    document.publication_state = "changes_not_sent_to_draft"
    document.last_editor = user if edited?(type)
    document.review_state = "unreviewed" unless in_review?(document)

    Document.transaction do
      document.save!
      TimelineEntry.create!(document: document, user: user, entry_type: type)
    end

    DocumentPublishingService.new.publish_draft(document)
  end

  def try_create_preview(args)
    create_preview(args)
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
  end

private

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
end
