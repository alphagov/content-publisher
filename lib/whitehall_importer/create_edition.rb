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
                  state = MigrateState.call(whitehall_edition["state"], whitehall_edition["force_published"])
                  status = build_status(state)
                  create_edition(status)
                end

      edition.tap { |e| access_limit(e) }
    end

  private

    def revision
      @revision ||= CreateRevision.call(document, whitehall_edition)
    end

    def check_only_in_english
      raise AbortImportError, "Edition has an unsupported locale" unless only_english_translation?
    end

    def only_english_translation?
      whitehall_edition["translations"].count == 1 && whitehall_edition["translations"].last["locale"] == "en"
    end

    def create_withdrawn_edition
      published_status = build_status("published")
      create_edition(published_status).tap { |edition| set_withdrawn_status(edition) }
    end

    def set_withdrawn_status(edition)
      withdrawn_status = build_status(
        MigrateState.call(whitehall_edition["state"], whitehall_edition["force_published"]),
        build_withdrawal(edition),
      )

      edition.update!(status: withdrawn_status)
    end

    def build_withdrawal(edition)
      raise AbortImportError, "Cannot create withdrawn status without an unpublishing" if whitehall_edition["unpublishing"].blank?

      Withdrawal.new(
        published_status: edition.status,
        public_explanation: whitehall_edition["unpublishing"]["explanation"],
        withdrawn_at: whitehall_edition["unpublishing"]["created_at"],
      )
    end

    def build_status(state, details = nil)
      Status.new(
        state: state,
        revision_at_creation: revision,
        created_by_id: user_ids[state_history_event["whodunnit"]],
        created_at: state_history_event["created_at"],
        details: details,
      )
    end

    def state_history_event
      event = whitehall_edition["revision_history"].select { |h| h["state"] == whitehall_edition["state"] }.last

      raise AbortImportError, "Edition is missing a #{whitehall_edition['state']} event" unless event

      event
    end

    def create_edition(status)
      create_event = create_history_event
      last_event = whitehall_edition["revision_history"].last

      Edition.create!(
        document: document,
        number: edition_number,
        revision_synced: true,
        revision: revision,
        status: status,
        current: current,
        live: whitehall_edition["state"].in?(%w(published withdrawn)),
        created_at: whitehall_edition["created_at"],
        updated_at: whitehall_edition["updated_at"],
        created_by_id: user_ids[create_event["whodunnit"]],
        last_edited_by_id: user_ids[last_event["whodunnit"]],
      )
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
