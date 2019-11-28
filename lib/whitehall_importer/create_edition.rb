# frozen_string_literal: true

module WhitehallImporter
  class CreateEdition
    attr_reader :document, :current, :whitehall_edition, :edition_number, :user_ids

    def self.call(*args)
      new(*args).call
    end

    def initialize(document:, whitehall_edition:, current: true, edition_number: 1, user_ids: {})
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
                elsif unpublished_edition? && history.edited_after_unpublishing?
                  split_unpublished_edition
                elsif unpublished_edition?
                  create_removed_edition
                else
                  state = MigrateState.call(whitehall_edition["state"], whitehall_edition["force_published"])
                  status = build_status(state)
                  create_edition(status: status, current: current, edition_number: edition_number)
                end

      edition.tap { |e| access_limit(e) }
    end

  private

    def revision
      @revision ||= CreateRevision.call(document, whitehall_edition)
    end

    def history
      @history ||= EditionHistory.new(whitehall_edition["revision_history"])
    end

    def unpublished_edition?
      whitehall_edition["unpublishing"] && %w[submitted rejected draft].include?(whitehall_edition["state"])
    end

    def split_unpublished_edition
      unpublishing_event = history.last_unpublishing_event
      create_edition(
        status: build_status("removed", build_removal),
        current: false,
        edition_number: edition_number,
        last_event: unpublishing_event,
      )

      create_edition(
        status: build_status(MigrateState.call(whitehall_edition["state"], whitehall_edition["force_published"])),
        edition_number: edition_number + 1,
        current: true,
        create_event: history.next_event(unpublishing_event),
      )
    end

    def create_removed_edition
      removed_status = build_status("removed", build_removal)
      create_edition(status: removed_status, current: current, edition_number: edition_number)
    end

    def check_only_in_english
      raise AbortImportError, "Edition has an unsupported locale" unless only_english_translation?
    end

    def only_english_translation?
      whitehall_edition["translations"].count == 1 && whitehall_edition["translations"].last["locale"] == "en"
    end

    def create_withdrawn_edition
      create_edition(status: build_status("published"),
                     current: current,
                     edition_number: edition_number).tap { |edition| set_withdrawn_status(edition) }
    end

    def set_withdrawn_status(edition)
      withdrawn_status = build_status(
        MigrateState.call(whitehall_edition["state"], whitehall_edition["force_published"]),
        build_withdrawal(edition),
      )

      edition.update!(status: withdrawn_status)
    end

    def build_removal
      unpublishing = whitehall_edition["unpublishing"]
      raise AbortImportError, "Cannot create removal status without an unpublishing" if unpublishing.blank?

      Removal.new(
        explanatory_note: unpublishing["explanation"],
        alternative_path: unpublishing["alternative_url"],
        redirect: unpublishing["alternative_url"].present?,
      )
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
      state_event = history.state_event(whitehall_edition["state"])

      Status.new(
        state: state,
        revision_at_creation: revision,
        created_by_id: user_ids[state_event["whodunnit"]],
        created_at: state_event["created_at"],
        details: details,
      )
    end

    def create_edition(status:, edition_number:, current:, create_event: nil, last_event: nil)
      create_event ||= history.create_event
      last_event ||= whitehall_edition["revision_history"].last

      Edition.create!(
        document: document,
        number: edition_number,
        revision_synced: true,
        revision: revision,
        status: status,
        current: current,
        live: whitehall_edition["state"].in?(%w(published withdrawn)),
        created_at: create_event["created_at"],
        updated_at: last_event["created_at"],
        created_by_id: user_ids[create_event["whodunnit"]],
        last_edited_by_id: user_ids[last_event["whodunnit"]],
      )
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
