# frozen_string_literal: true

class WhitehallImporter::CreateEdition
  attr_reader :document, :whitehall_document, :whitehall_edition, :edition_number, :most_recent_edition_id, :user_ids

  def initialize(document, whitehall_document, whitehall_edition, edition_number, most_recent_edition_id, user_ids)
    @document = document
    @whitehall_document = whitehall_document
    @whitehall_edition = whitehall_edition
    @edition_number = edition_number
    @most_recent_edition_id = most_recent_edition_id
    @user_ids = user_ids
  end

  def call
    create_event = create_history_event(whitehall_edition)
    last_event = whitehall_edition["revision_history"].last

    revision = WhitehallImporter::CreateRevision.new(
      document, whitehall_edition, english_translation
    ).call

    edition = Edition.create!(
      document: document,
      number: edition_number,
      revision_synced: true,
      revision: revision,
      status: initial_status(whitehall_edition, revision),
      current: whitehall_edition["id"] == most_recent_edition_id,
      live: live?(whitehall_edition),
      created_at: whitehall_edition["created_at"],
      updated_at: whitehall_edition["updated_at"],
      created_by_id: user_ids[create_event["whodunnit"]],
      last_edited_by_id: user_ids[last_event["whodunnit"]],
    )

    set_withdrawn_status(whitehall_edition, edition) if whitehall_edition["state"] == "withdrawn"
  end

private

  def english_translation
    raise WhitehallImporter::AbortImportError, "Edition has an unsupported locale" unless valid_translations?

    whitehall_edition["translations"].last
  end

  def valid_translations?
    whitehall_edition["translations"].count == 1 && whitehall_edition["translations"].last["locale"] == "en"
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
      raise WhitehallImporter::AbortImportError, "Cannot create withdrawn status without an unpublishing"
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

  def state_history_event(whitehall_edition, state)
    event = whitehall_edition["revision_history"].select { |h| h["state"] == state }.last

    raise WhitehallImporter::AbortImportError, "Edition is missing a #{state} event" unless event

    event
  end

  def create_history_event(whitehall_edition)
    event = whitehall_edition["revision_history"].select { |h| h["event"] == "create" }
      .first

    raise WhitehallImporter::AbortImportError, "Edition is missing a create event" unless event

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
end
