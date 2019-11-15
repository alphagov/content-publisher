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
  SUPPORTED_DOCUMENT_TYPES = %w(news_story press_release).freeze
  DOCUMENT_SUB_TYPES = %w[
      news_article_type
      publication_type
      corporate_information_page_type
      speech_type
  ].freeze

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

    document_type_key = DOCUMENT_SUB_TYPES.reject { |t| whitehall_edition[t].nil? }.first
    raise AbortImportError, "Edition has an unsupported document type" unless SUPPORTED_DOCUMENT_TYPES.include?(whitehall_edition[document_type_key])

    revision = Revision.create!(
      document: document,
      number: document.next_revision_number,
      imported: true,
      content_revision: ContentRevision.new(
        title: translation["title"],
        base_path: translation["base_path"],
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

  class AbortImportError < RuntimeError
    def initialize(message)
      super(message)
    end
  end
end
