# frozen_string_literal: true

class DocumentDraftingService
  def self.update!(document:, user:, type:)
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

  def self.edited?(type)
    %w(updated_content updated_tags).include?(type)
  end

  def self.in_review?(document)
    document.review_state == "submitted_for_review"
  end

  def self.published?(document)
    document.publication_state == "sent_to_live"
  end

  def self.create_new_edition(document)
    document.current_edition_number += 1
    document.change_note = nil
    document.update_type = "major"
  end
end
