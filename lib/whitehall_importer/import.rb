# frozen_string_literal: true

module WhitehallImporter
  class Import
    attr_reader :whitehall_document, :user_ids

    def self.call(*args)
      new(*args).call
    end

    def initialize(whitehall_document)
      @whitehall_document = whitehall_document
      @user_ids = {}
    end

    def call
      ActiveRecord::Base.transaction do
        create_users(whitehall_document["users"])
        document = create_or_update_document

        whitehall_document["editions"].each_with_index do |edition, edition_number|
          CreateEdition.call(
            document, whitehall_document, edition, edition_number + 1, user_ids
          )
        end
      end
    end

  private

    def create_users(users)
      users.each do |user|
        user_keys = %w[uid name email organisation_slug organisation_content_id]
        content_publisher_user = User.create_with(user.slice(*user_keys).merge("permissions" => [])).find_or_create_by!(uid: user["uid"])
        user_ids[user["id"]] = content_publisher_user["id"]
      end
    end

    def create_or_update_document
      event = whitehall_document["editions"].first["revision_history"].select { |h| h["event"] == "create" }.first

      raise AbortImportError, "First edition is missing a create event" unless event

      Document.find_or_create_by!(
        content_id: whitehall_document["content_id"],
        locale: "en",
        created_at: whitehall_document["created_at"],
        updated_at: whitehall_document["updated_at"],
        created_by_id: user_ids[event["whodunnit"]],
        imported_from: "whitehall",
      )
    end
  end
end
