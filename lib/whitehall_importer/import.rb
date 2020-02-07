# frozen_string_literal: true

module WhitehallImporter
  class Import
    attr_reader :document_import

    def self.call(*args)
      new(*args).call
    end

    def initialize(document_import)
      @document_import = document_import
    end

    def call
      unless document_import.pending?
        raise "Cannot import with a state of #{document_import.state}"
      end

      document_import.update!(
        payload: whitehall_document,
        content_id: whitehall_document["content_id"],
      )

      ActiveRecord::Base.transaction do
        user_ids = create_users(whitehall_document["users"])
        document_import.document = create_document(user_ids)

        whitehall_document["editions"].each_with_index do |edition, edition_number|
          CreateEdition.call(
            document_import: document_import,
            current: current?(edition),
            whitehall_edition: edition,
            edition_number: edition_number + 1,
            user_ids: user_ids,
          )
        end

        check_document_integrity(document_import.document)

        create_timeline_entry(document_import.document.current_edition)

        document_import.update!(state: "imported")
        document_import
      end
    rescue StandardError
      # restore any attributes set during import
      document_import.reload
      raise
    end

  private

    def whitehall_document
      @whitehall_document ||= GdsApi.whitehall_export
                                    .document_export(document_import.whitehall_document_id)
                                    .to_h
    end

    def create_timeline_entry(edition)
      details = TimelineEntry::WhitehallImportedEntry.create!(
        entry_type: :imported_from_whitehall,
      )
      TimelineEntry.create_for_revision(
        entry_type: :whitehall_migration,
        revision: edition.revision,
        edition: edition,
        details: details,
      )
    end

    def current?(edition)
      edition["id"] == whitehall_document["editions"].max_by { |e| e["created_at"] }["id"]
    end

    def create_users(users)
      user_keys = %w[uid name email organisation_slug organisation_content_id]

      users.each_with_object({}) do |user, memo|
        next if user["uid"].blank?

        attributes = user.slice(*user_keys).merge("permissions" => [])
        user_object = User.find_by(uid: user["uid"]) || User.create!(attributes)
        memo[user["id"]] = user_object.id
      end
    end

    def create_document(user_ids)
      content_id = whitehall_document["content_id"]
      if Document.exists?(content_id: content_id)
        raise AbortImportError, "Document with content_id #{content_id} already exists"
      end

      event = first_edition_history.create_event!

      Document.create!(
        content_id: content_id,
        locale: "en",
        created_at: whitehall_document["created_at"],
        updated_at: whitehall_document["updated_at"],
        created_by_id: user_ids[event["whodunnit"]],
        first_published_at: first_publish_date,
        imported_from: "whitehall",
      )
    end

    def first_publish_date
      first_publish_event = first_edition_history.first_state_event("published") || {}
      first_publish_event["created_at"]
    end

    def first_edition_history
      EditionHistory.new(whitehall_document["editions"].first["revision_history"])
    end

    def check_document_integrity(document)
      check_edition_integrity(document.live_edition) if document.live_edition
      check_edition_integrity(document.current_edition) if document.current_edition != document.live_edition
    end

    def check_edition_integrity(edition)
      integrity_checker = IntegrityChecker.new(edition)

      unless integrity_checker.valid?
        raise WhitehallImporter::IntegrityCheckError.new(integrity_checker)
      end
    end
  end
end
