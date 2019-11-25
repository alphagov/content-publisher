# frozen_string_literal: true

module WhitehallImporter
  class EditionHistory
    def initialize(revision_history)
      @revision_history = revision_history
    end

    def state_event(state)
      event = revision_history.select { |h| h["state"] == state }.last

      raise AbortImportError, "Edition is missing a #{state} event" unless event

      event
    end

    def create_event
      event = revision_history.select { |h| h["event"] == "create" }.first

      raise AbortImportError, "Edition is missing a create event" unless event

      event
    end

  private
    attr_reader :revision_history
  end
end
