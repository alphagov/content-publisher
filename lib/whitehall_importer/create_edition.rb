# frozen_string_literal: true

class WhitehallImporter::CreateEdition
  attr_reader :document, :whitehall_document, :whitehall_edition, :edition_number, :user_ids

  SUPPORTED_WHITEHALL_STATES = %w(
      draft
      published
      rejected
      submitted
      superseded
      withdrawn
  ).freeze

  def initialize(document, whitehall_document, whitehall_edition, edition_number, user_ids)
    @document = document
    @whitehall_document = whitehall_document
    @whitehall_edition = whitehall_edition
    @edition_number = edition_number
    @user_ids = user_ids
  end

  def call
    check_supported_state
    check_only_in_english

    if whitehall_edition["state"] == "withdrawn"
      create_withdrawn_edition
    else
      create_edition
    end
  end

private

  def check_supported_state
    raise WhitehallImporter::AbortImportError, "Edition has an unsupported state" unless valid_state?
  end

  def valid_state?
    SUPPORTED_WHITEHALL_STATES.include?(whitehall_edition["state"])
  end

  def check_only_in_english
    raise WhitehallImporter::AbortImportError, "Edition has an unsupported locale" unless only_english_translation?
  end

  def only_english_translation?
    whitehall_edition["translations"].count == 1 && whitehall_edition["translations"].last["locale"] == "en"
  end

  def english_translation
    whitehall_edition["translations"].last
  end

  def create_withdrawn_edition
    edition = create_edition("published")
    set_withdrawn_status(edition)
  end

  def create_edition(initial_state = whitehall_edition["state"])
    create_event = create_history_event
    last_event = whitehall_edition["revision_history"].last

    revision = WhitehallImporter::CreateRevision.new(
      document, whitehall_edition, english_translation
    ).call

    Edition.create!(
      document: document,
      number: edition_number,
      revision_synced: true,
      revision: revision,
      status: WhitehallImporter::CreateStatus.new(
        revision, initial_state, whitehall_edition, user_ids
      ).call,
      current: whitehall_edition["id"] == most_recent_edition["id"],
      live: live?,
      created_at: whitehall_edition["created_at"],
      updated_at: whitehall_edition["updated_at"],
      created_by_id: user_ids[create_event["whodunnit"]],
      last_edited_by_id: user_ids[last_event["whodunnit"]],
    )
  end

  def set_withdrawn_status(edition)
    if whitehall_edition["unpublishing"].blank?
      raise WhitehallImporter::AbortImportError, "Cannot create withdrawn status without an unpublishing"
    end

    event = state_history_event("withdrawn")

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

  def state_history_event(state)
    event = whitehall_edition["revision_history"].select { |h| h["state"] == state }.last

    raise WhitehallImporter::AbortImportError, "Edition is missing a #{state} event" unless event

    event
  end

  def create_history_event
    event = whitehall_edition["revision_history"].select { |h| h["event"] == "create" }
      .first

    raise WhitehallImporter::AbortImportError, "Edition is missing a create event" unless event

    event
  end

  def live?
    whitehall_edition["state"].in?(%w(published withdrawn))
  end

  def most_recent_edition
    whitehall_document["editions"].max_by { |e| e["created_at"] }
  end
end
