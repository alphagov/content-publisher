# frozen_string_literal: true

module WhitehallImporter
  class CreateEdition
    attr_reader :document, :current, :whitehall_edition, :edition_number, :user_ids

    def self.call(*args)
      new(*args).call
    end

    def initialize(document:, current:, whitehall_edition:, edition_number:, user_ids:)
      @document = document
      @current = current
      @whitehall_edition = whitehall_edition
      @edition_number = edition_number
      @user_ids = user_ids
    end

    def call
      check_only_in_english

      edition = if whitehall_edition["state"] == "withdrawn"
                  create_withdrawn_edition
                else
                  create_edition
                end

      edition.tap { |e| access_limit(e) }
    end

  private

    def check_only_in_english
      raise AbortImportError, "Edition has an unsupported locale" unless only_english_translation?
    end

    def only_english_translation?
      whitehall_edition["translations"].count == 1 && whitehall_edition["translations"].last["locale"] == "en"
    end

    def create_withdrawn_edition
      create_edition("published").tap { |edition| set_withdrawn_status(edition) }
    end

    def create_edition(whitehall_edition_state = nil)
      create_event = create_history_event
      last_event = whitehall_edition["revision_history"].last

      revision = CreateRevision.call(document, whitehall_edition)

      Edition.create!(
        document: document,
        number: edition_number,
        revision_synced: true,
        revision: revision,
        status: CreateStatus.call(
          revision, whitehall_edition, user_ids, whitehall_edition_state: whitehall_edition_state
        ),
        current: current,
        live: whitehall_edition["state"].in?(%w(published withdrawn)),
        created_at: whitehall_edition["created_at"],
        updated_at: whitehall_edition["updated_at"],
        created_by_id: user_ids[create_event["whodunnit"]],
        last_edited_by_id: user_ids[last_event["whodunnit"]],
      )
    end

    def set_withdrawn_status(edition)
      edition.status = CreateStatus.call(
        edition.revision,
        whitehall_edition,
        user_ids,
        edition: edition,
      )

      edition.save!
    end

    def create_history_event
      event = whitehall_edition["revision_history"].select { |h| h["event"] == "create" }
        .first

      raise AbortImportError, "Edition is missing a create event" unless event

      event
    end

    def access_limit(edition)
      return unless whitehall_edition["access_limited"]

      edition.access_limit = AccessLimit.new(
        created_at: whitehall_edition["created_at"],
        edition: edition,
        revision_at_creation: edition.revision,
        limit_type: "tagged_organisations",
      )

      edition.save!
    end
  end
end
