# frozen_string_literal: true

class WhitehallImporter
  attr_reader :whitehall_document, :whitehall_import, :user_ids

  SUPPORTED_WHITEHALL_STATES = %w(
      draft
      published
      rejected
      submitted
      superseded
      withdrawn
  ).freeze
  SUPPORTED_LOCALES = %w(en).freeze

  def initialize(whitehall_document)
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

  def update_state(state)
    whitehall_import.update_attribute(:state, state)
  end

  def log_error(error)
    whitehall_import.update_attribute(:error_log, error)
  end

private

  def store_json_blob
    WhitehallImport.create(
      whitehall_document_id: whitehall_document["id"],
      payload: whitehall_document,
      content_id: whitehall_document["content_id"],
      state: "importing",
    )
  end

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
    event = create_history_event(whitehall_document["editions"].first)

    Document.find_or_create_by!(
      content_id: whitehall_document["content_id"],
      locale: "en",
      created_at: whitehall_document["created_at"],
      updated_at: whitehall_document["updated_at"],
      created_by_id: user_ids[event["whodunnit"]],
      imported_from: "whitehall",
    )
  end

  def create_edition(document, translation, whitehall_edition, edition_number)
    create_event = create_history_event(whitehall_edition)
    last_event = whitehall_edition["revision_history"].last

    revision = WhitehallImporter::CreateRevision.new(
      document, whitehall_edition, translation
    ).call

    edition = Edition.create!(
      document: document,
      number: edition_number,
      revision_synced: true,
      revision: revision,
      status: initial_status(whitehall_edition, revision),
      current: whitehall_edition["id"] == most_recent_edition["id"],
      live: live?(whitehall_edition),
      created_at: whitehall_edition["created_at"],
      updated_at: whitehall_edition["updated_at"],
      created_by_id: user_ids[create_event["whodunnit"]],
      last_edited_by_id: user_ids[last_event["whodunnit"]],
    )

    set_withdrawn_status(whitehall_edition, edition) if whitehall_edition["state"] == "withdrawn"
  end

  def initial_status(whitehall_edition, revision)
    event = if whitehall_edition["state"] == "withdrawn"
              state_history_event(whitehall_edition, "published")
            else
              state_history_event(whitehall_edition, whitehall_edition["state"])
            end

    Status.new(
      state: state(whitehall_edition),
      revision_at_creation: revision,
      created_by_id: user_ids[event["whodunnit"]],
      created_at: event["created_at"],
    )
  end

  def set_withdrawn_status(whitehall_edition, edition)
    if whitehall_edition["unpublishing"].blank?
      raise AbortImportError, "Cannot create withdrawn status without an unpublishing"
    end

    event = state_history_event(whitehall_edition, "withdrawn")

    edition.status = Status.new(
      state: "withdrawn",
      revision_at_creation: edition.revision,
      created_by_id: user_ids[event["whodunnit"]],
      created_at: event["created_at"],
      details: Withdrawal.new(
        published_status: edition.status,
        public_explanation: whitehall_edition["unpublishing"]["explanation"],
        withdrawn_at: whitehall_edition["unpublishing"]["created_at"],
      ),
    )

    edition.save!
  end

  def create_history_event(whitehall_edition)
    event = whitehall_edition["revision_history"].select { |h| h["event"] == "create" }
      .first

    raise AbortImportError, "Edition is missing a create event" unless event

    event
  end

  def state_history_event(whitehall_edition, state)
    event = whitehall_edition["revision_history"].select { |h| h["state"] == state }.last

    raise AbortImportError, "Edition is missing a #{state} event" unless event

    event
  end

  def state(whitehall_edition)
    case whitehall_edition["state"]
    when "draft" then "draft"
    when "superseded" then "superseded"
    when "published", "withdrawn"
      whitehall_edition["force_published"] ? "published_but_needs_2i" : "published"
    else
      "submitted_for_review"
    end
  end

  def live?(whitehall_edition)
    whitehall_edition["state"].in?(%w(published withdrawn))
  end

  class AbortImportError < RuntimeError
    def initialize(message)
      super(message)
    end
  end
end
