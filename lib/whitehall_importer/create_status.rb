# frozen_string_literal: true

module WhitehallImporter
  class CreateStatus
    attr_reader :revision, :whitehall_edition_state, :whitehall_edition, :user_ids, :edition

    SUPPORTED_WHITEHALL_STATES = %w(
      draft
      published
      rejected
      submitted
      superseded
      withdrawn
    ).freeze

    def self.call(*args)
      new(*args).call
    end

    def initialize(revision, whitehall_edition, user_ids, whitehall_edition_state: nil, edition: nil)
      @revision = revision
      @whitehall_edition = whitehall_edition
      @whitehall_edition_state = whitehall_edition_state || whitehall_edition["state"]
      @user_ids = user_ids
      @edition = edition
    end

    def call
      check_supported_state

      Status.new(
        state: state,
        revision_at_creation: revision,
        created_by_id: user_ids[state_history_event["whodunnit"]],
        created_at: state_history_event["created_at"],
        details: details,
      )
    end

  private

    def check_supported_state
      raise AbortImportError, "Edition has an unsupported state" unless valid_state?
    end

    def valid_state?
      SUPPORTED_WHITEHALL_STATES.include?(whitehall_edition_state)
    end

    def state_history_event
      event = whitehall_edition["revision_history"].select { |h| h["state"] == whitehall_edition_state }.last

      raise AbortImportError, "Edition is missing a #{whitehall_edition_state} event" unless event

      event
    end

    def state
      case whitehall_edition_state
      when "draft" then "draft"
      when "superseded" then "superseded"
      when "published"
        whitehall_edition["force_published"] ? "published_but_needs_2i" : "published"
      when "withdrawn" then "withdrawn"
      else
        "submitted_for_review"
      end
    end

    def details
      if edition && whitehall_edition_state == "withdrawn"
        if whitehall_edition["unpublishing"].blank?
          raise AbortImportError, "Cannot create withdrawn status without an unpublishing"
        end

        Withdrawal.new(
          published_status: edition.status,
          public_explanation: whitehall_edition["unpublishing"]["explanation"],
          withdrawn_at: whitehall_edition["unpublishing"]["created_at"],
        )
      end
    end
  end
end
