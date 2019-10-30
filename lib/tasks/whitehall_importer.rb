# frozen_string_literal: true

module Tasks
  class WhitehallImporter
    attr_reader :whitehall_document_id, :whitehall_document, :whitehall_import

    SUPPORTED_WHITEHALL_STATES = %w(draft published rejected submitted superseded).freeze
    SUPPORTED_LOCALES = %w(en).freeze

    def initialize(whitehall_document_id, whitehall_document)
      @whitehall_document_id = whitehall_document_id
      @whitehall_document = whitehall_document
      @whitehall_import = store_json_blob
    end

    def import
      ActiveRecord::Base.transaction do
        document = create_or_update_document

        whitehall_document["editions"].each_with_index do |edition, edition_number|
          edition["translations"].each do |translation|
            next unless SUPPORTED_WHITEHALL_STATES.include?(edition["state"])
            next unless SUPPORTED_LOCALES.include?(translation["locale"])

            create_edition(document, translation, edition, edition_number + 1)
          end
        end
      end
    end

    def store_json_blob
      WhitehallImport.create(
        whitehall_document_id: whitehall_document_id,
        payload: whitehall_document,
        content_id: whitehall_document["content_id"],
        state: "importing",
      )
    end

    def update_state(state)
      whitehall_import.update_attribute(:state, state)
    end

    def log_error(error)
      whitehall_import.update_attribute(:error_log, error)
    end

  private

    def most_recent_edition
      whitehall_document["editions"].max_by { |e| e["created_at"] }
    end

    def create_or_update_document
      Document.find_or_create_by(
        content_id: whitehall_document["content_id"],
        locale: "en",
        document_type_id: "news_story", ## To be updated once Whitehall exports this value
        created_at: whitehall_document["created_at"],
        updated_at: whitehall_document["updated_at"],
        imported_from: "whitehall",
      )
    end

    def create_edition(document, translation, whitehall_edition, edition_number)
      revision = Revision.create!(
        document: document,
        number: document.next_revision_number,
        imported: true,
        content_revision: ContentRevision.new(
          title: translation["title"],
          base_path: "/government/news/" + whitehall_document["slug"],
          summary: translation["summary"],
          contents: {
            body: embed_contacts(translation["body"], whitehall_edition.fetch("contacts", [])),
          },
        ),
        metadata_revision: MetadataRevision.new(
          update_type: whitehall_edition["minor_change"] ? "minor" : "major",
          change_note: whitehall_edition["change_note"],
        ),
        tags_revision: TagsRevision.new(
          tags: {
            "primary_publishing_organisation" => primary_publishing_organisation(whitehall_edition["organisations"]),
            "organisations" => supporting_organisations(whitehall_edition["organisations"]),
          },
        ),
        created_at: whitehall_edition["created_at"],
      )

      Edition.create!(
        document: document,
        number: edition_number,
        revision_synced: true,
        revision: revision,
        status: Status.new(
          state: state(whitehall_edition),
          revision_at_creation: revision,
        ),
        current: whitehall_edition["id"] == most_recent_edition["id"],
        live: live?(whitehall_edition),
        created_at: whitehall_edition["created_at"],
        updated_at: whitehall_edition["updated_at"],
      )
    end

    def state(whitehall_edition)
      case whitehall_edition["state"]
      when "draft" then "draft"
      when "superseded" then "superseded"
      when "published"
        whitehall_edition["force_published"] ? "published_but_needs_2i" : "published"
      else
        "submitted_for_review"
      end
    end

    def live?(whitehall_edition)
      whitehall_edition["state"] == "published"
    end

    def embed_contacts(body, contacts)
      body&.gsub(/\[Contact:\s*(\d*)\s*\]/) do
        id = Regexp.last_match[1].to_i
        embed = contacts.select { |x| x["id"] == id }.first["content_id"]
        "[Contact:#{embed}]"
      end
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
  end

  class AbortImportError < RuntimeError; end
end
