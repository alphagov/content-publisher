# frozen_string_literal: true

module WhitehallImporter
  class EditionHistory
    def self.state_event(whitehall_edition)
      event = whitehall_edition["revision_history"].select { |h| h["state"] == whitehall_edition["state"] }.last

      raise AbortImportError, "Edition is missing a #{whitehall_edition['state']} event" unless event

      event
    end

    def self.create_event(whitehall_edition)
      event = whitehall_edition["revision_history"].select { |h| h["event"] == "create" }.first

      raise AbortImportError, "Edition is missing a create event" unless event

      event
    end
  end
end
