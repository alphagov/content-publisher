# frozen_string_literal: true

module WhitehallImporter
  class MigrateState
    attr_reader :whitehall_state, :force_published

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

    def initialize(whitehall_state, force_published)
      @whitehall_state = whitehall_state
      @force_published = force_published
    end

    def call
      raise AbortImportError, "Unsupported whitehall state #{whitehall_state}" unless valid_state?

      case whitehall_state
      when "draft" then "draft"
      when "superseded" then "superseded"
      when "published"
        force_published ? "published_but_needs_2i" : "published"
      when "withdrawn" then "withdrawn"
      else
        "submitted_for_review"
      end
    end

  private

    def valid_state?
      SUPPORTED_WHITEHALL_STATES.include?(whitehall_state)
    end
  end
end
