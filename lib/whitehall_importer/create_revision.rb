# frozen_string_literal: true

module WhitehallImporter
  class CreateRevision
    attr_reader :document, :whitehall_edition

    SUPPORTED_DOCUMENT_TYPES = %w(news_story press_release).freeze
    DOCUMENT_SUB_TYPES = %w[
      news_article_type
      publication_type
      corporate_information_page_type
      speech_type
    ].freeze

    def self.call(*args)
      new(*args).call
    end

    def initialize(document, whitehall_edition)
      @document = document
      @whitehall_edition = whitehall_edition
    end

    def call
      document_type_key = DOCUMENT_SUB_TYPES.reject { |t| whitehall_edition[t].nil? }.first
      raise AbortImportError, "Edition has an unsupported document type" unless SUPPORTED_DOCUMENT_TYPES.include?(whitehall_edition[document_type_key])

      file_attachment_revisions = create_file_attachment_revisions(whitehall_edition["attachments"])
      image_revisions = create_image_revisions(whitehall_edition["images"])
      Revision.create!(
        document: document,
        number: document.next_revision_number,
        imported: true,
        content_revision: ContentRevision.new(
          title: translation["title"],
          base_path: translation["base_path"],
          summary: translation["summary"],
          contents: {
            body: WhitehallImporter::EmbedBodyReferences.call(
              body: translation["body"],
              contacts: whitehall_edition.fetch("contacts", []),
              images: image_revisions.map(&:filename),
              attachments: file_attachment_revisions.map(&:filename),
            ),
          },
        ),
        metadata_revision: MetadataRevision.new(
          update_type: whitehall_edition["minor_change"] ? "minor" : "major",
          change_note: whitehall_edition["change_note"],
          document_type_id: whitehall_edition[document_type_key],
        ),
        tags_revision: TagsRevision.new(
          tags: {
            "primary_publishing_organisation" => primary_publishing_organisation(whitehall_edition["organisations"]),
            "organisations" => supporting_organisations(whitehall_edition["organisations"]),
            "role_appointments" => tags(whitehall_edition["role_appointments"]),
            "topical_events" => tags(whitehall_edition["topical_events"]),
            "world_locations" => tags(whitehall_edition["world_locations"]),
          },
        ),
        image_revisions: image_revisions,
        file_attachment_revisions: file_attachment_revisions,
        lead_image_revision: image_revisions.first,
        created_at: whitehall_edition["created_at"],
      )
    end

  private

    def translation
      @translation ||= whitehall_edition["translations"].find do |t|
        t["locale"] == document.locale
      end

      @translation || raise(AbortImportError, "Translation #{document.locale} missing")
    end

    def primary_publishing_organisation(organisations)
      unless organisations
        raise AbortImportError, "Must have at least one organisation"
      end

      primary_publishing_organisations = organisations.select do |organisation|
        organisation["lead"]
      end

      unless primary_publishing_organisations.any?
        raise AbortImportError, "Lead organisation missing"
      end

      if primary_publishing_organisations.count > 1
        raise AbortImportError, "Cannot have more than one lead organisation"
      end

      primary_publishing_organisation = primary_publishing_organisations.min { |o| o["lead_ordering"] }

      [primary_publishing_organisation["content_id"]]
    end

    def supporting_organisations(organisations)
      supporting_organisations = organisations.reject do |organisation|
        organisation["lead"]
      end

      supporting_organisations.map { |organisation| organisation["content_id"] }
    end

    def tags(associations)
      return [] unless associations

      associations.map { |association| association["content_id"] }
    end

    def create_image_revisions(images)
      images.reduce([]) do |memo, image|
        memo << WhitehallImporter::CreateImageRevision.call(image, memo.map(&:filename))
      end
    end

    def create_file_attachment_revisions(file_attachments)
      file_attachments.reduce([]) do |memo, file_attachment|
        memo << WhitehallImporter::CreateFileAttachmentRevision.call(file_attachment, memo.map(&:filename))
      end
    end
  end
end
