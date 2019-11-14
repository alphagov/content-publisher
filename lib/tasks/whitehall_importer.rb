# frozen_string_literal: true

module Tasks
  class WhitehallImporter
    attr_reader :whitehall_document_id, :whitehall_document, :whitehall_import, :user_ids

    SUPPORTED_WHITEHALL_STATES = %w(draft published rejected submitted superseded).freeze
    SUPPORTED_LOCALES = %w(en).freeze
    SUPPORTED_DOCUMENT_TYPES = %w(news_story press_release).freeze
    DOCUMENT_SUB_TYPES = %w[
      news_article_type
      publication_type
      corporate_information_page_type
      speech_type
    ].freeze


    def initialize(whitehall_document_id, whitehall_document)
      @whitehall_document_id = whitehall_document_id
      @whitehall_document = whitehall_document
      @whitehall_import = store_json_blob
      @user_ids = {}
    end

    def import
      ActiveRecord::Base.transaction do
        create_users(whitehall_document["users"])
        document = create_or_update_document

        whitehall_document["editions"].each_with_index do |edition, edition_number|
          edition["translations"].each do |translation|
            raise AbortImportError, "Edition has an unsupported state" unless SUPPORTED_WHITEHALL_STATES.include?(edition["state"])
            raise AbortImportError, "Edition has an unsupported locale" unless SUPPORTED_LOCALES.include?(translation["locale"])

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

    def create_users(users)
      users.each do |user|
        user_keys = %w[uid name email organisation_slug organisation_content_id]
        content_publisher_user = User.create_with(user.slice(*user_keys).merge("permissions" => [])).find_or_create_by!(uid: user["uid"])
        user_ids[user["id"]] = content_publisher_user["id"]
      end
    end

    def most_recent_edition
      whitehall_document["editions"].max_by { |e| e["created_at"] }
    end

    def create_or_update_document
      first_edition = whitehall_document["editions"].first
      first_author = first_edition["revision_history"].select { |h| h["event"] == "create" }.first

      Document.find_or_create_by!(
        content_id: whitehall_document["content_id"],
        locale: "en",
        created_at: whitehall_document["created_at"],
        updated_at: whitehall_document["updated_at"],
        created_by_id: user_ids[first_author["whodunnit"]],
        imported_from: "whitehall",
      )
    end

    def create_edition(document, translation, whitehall_edition, edition_number)
      first_author = whitehall_edition["revision_history"].select { |h| h["event"] == "create" }.first
      last_author = whitehall_edition["revision_history"].last

      document_type_key = DOCUMENT_SUB_TYPES.reject { |t| whitehall_edition[t].nil? }.first
      raise AbortImportError, "Edition has an unsupported document type" unless SUPPORTED_DOCUMENT_TYPES.include?(whitehall_edition[document_type_key])

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
        created_by_id: user_ids[first_author["whodunnit"]],
        last_edited_by_id: user_ids[last_author["whodunnit"]],
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

    def tags(associations)
      return [] unless associations

      associations.map { |association| association["content_id"] }
    end
  end

  class AbortImportError < RuntimeError; end
end
