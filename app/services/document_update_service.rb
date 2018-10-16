# frozen_string_literal: true

class DocumentUpdateService
  def self.update!(document:, user:, type:, attributes_to_update:)
    if document.publication_state == "sent_to_live"
      document.current_edition_number += 1
    end

    document.publication_state = "changes_not_sent_to_draft"
    document.last_editor = user if document_edited?(type)
    document.review_state = "unreviewed" unless in_review?(document)
    document.assign_attributes(attributes_to_update)

    Document.transaction do
      document.save!
      TimelineEntry.create!(document: document, user: user, entry_type: type)
    end

    DocumentPublishingService.new.publish_draft(document)
  end

  def self.document_edited?(type)
    %w(updated_content updated_tags).include?(type)
  end

  def self.in_review?(document)
    document.review_state == "submitted_for_review"
  end
end
