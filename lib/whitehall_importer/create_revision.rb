# frozen_string_literal: true

module WhitehallImporter
  class CreateRevision
    attr_reader :document_import, :whitehall_edition

    delegate :document, to: :document_import

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

    def initialize(document_import, whitehall_edition)
      @document_import = document_import
      @whitehall_edition = whitehall_edition
    end

    def call
      document_type_key = DOCUMENT_SUB_TYPES.reject { |t| whitehall_edition[t].nil? }.first
      raise AbortImportError, "Edition has an unsupported document type" unless SUPPORTED_DOCUMENT_TYPES.include?(whitehall_edition[document_type_key])

      file_attachment_revisions = find_or_create_file_attachment_revisions(whitehall_edition["attachments"])
      image_revisions = image_revisions(whitehall_edition["images"])
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
          backdated_to: backdated? ? whitehall_edition["first_published_at"] : nil,
        ),
        tags_revision: TagsRevision.new(
          tags: {
            "primary_publishing_organisation" => primary_publishing_organisation,
            "organisations" => supporting_organisations,
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

    def history
      @history ||= EditionHistory.new(whitehall_edition["revision_history"])
    end

    def translation
      @translation ||= whitehall_edition["translations"].find do |t|
        t["locale"] == document.locale
      end

      @translation || raise(AbortImportError, "Translation #{document.locale} missing")
    end

    def primary_publishing_organisation
      unless whitehall_edition["organisations"]
        raise AbortImportError, "Must have at least one organisation"
      end

      unless lead_organisations.any?
        raise AbortImportError, "Lead organisation missing"
      end

      [lead_organisations.first["content_id"]]
    end

    def supporting_organisations
      supporting_organisations = whitehall_edition["organisations"].reject do |organisation|
        lead_organisations.first == organisation
      end

      supporting_organisations.map { |organisation| organisation["content_id"] }
    end

    def lead_organisations
      lead_orgs = whitehall_edition["organisations"].select do |organisation|
        organisation["lead"]
      end

      lead_orgs.sort_by { |organisation| organisation["lead_ordering"] }
    end

    def tags(associations)
      return [] unless associations

      associations.map { |association| association["content_id"] }
    end

    def image_revisions(images)
      images.reduce([]) do |memo, image|
        memo << find_or_create_image_revision(memo, image)
      end
    end

    def find_or_create_image_revision(memo, image)
      already_imported = WhitehallMigration::AssetImport.find_by(original_asset_url: image["url"])
      if already_imported &&
          (already_imported.image_revision.alt_text != image["alt_text"] ||
           already_imported.image_revision.caption != image["caption"])
        Image::Revision.create!(
          image: already_imported.image_revision.image,
          metadata_revision: Image::MetadataRevision.new(
            caption: image["caption"],
            alt_text: image["alt_text"],
          ),
          blob_revision: already_imported.image_revision.blob_revision,
        )
      elsif already_imported
        already_imported.image_revision
      else
        WhitehallImporter::CreateImageRevision
          .call(document_import, image, memo.map(&:filename))
      end
    end

    def find_or_create_file_attachment_revisions(file_attachments)
      file_attachments.reduce([]) do |memo, file_attachment|
        already_imported = WhitehallMigration::AssetImport.find_by(original_asset_url: file_attachment["url"])
        revision = if already_imported
                     already_imported.file_attachment_revision
                   else
                     WhitehallImporter::CreateFileAttachmentRevision
                       .call(document_import, file_attachment, memo.map(&:filename))
                   end
        memo << revision
      end
    end

    def backdated?
      first_publish_event = history.first_state_event("publish") || {}
      whitehall_edition["first_published_at"] != first_publish_event["created_at"]
    end
  end
end
