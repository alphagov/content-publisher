# frozen_string_literal: true

module WhitehallImporter
  class Import
    attr_reader :whitehall_document

    def self.call(*args)
      new(*args).call
    end

    def initialize(whitehall_document)
      @whitehall_document = whitehall_document
    end

    def call
      ActiveRecord::Base.transaction do
        user_ids = create_users(whitehall_document["users"])
        document = create_document(user_ids)

        whitehall_document["editions"].each_with_index do |edition, edition_number|
          CreateEdition.call(
            document: document,
            current: current?(edition),
            whitehall_edition: edition,
            edition_number: edition_number + 1,
            user_ids: user_ids,
          )
        end

        check_document_integrity(document)
        document
      end
    end

  private

    def current?(edition)
      edition["id"] == whitehall_document["editions"].max_by { |e| e["created_at"] }["id"]
    end

    def create_users(users)
      users.each_with_object({}) do |user, memo|
        user_keys = %w[uid name email organisation_slug organisation_content_id]
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

      raise AbortImportError, integrity_checker.problems.join(", ") unless integrity_checker.valid?
    end
  end
end
