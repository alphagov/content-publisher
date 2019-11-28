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

    def last_unpublishing_event
      # we can determine the event that marks an unpublishing by a draft event following a published event
      unpublishing_events = revision_history.select.with_index do |item, index|
        next unless item["state"] == "draft"

        previous_entry = revision_history[index - 1]
        previous_entry && previous_entry["state"] == "published"
      end

      raise AbortImportError, "Edition is missing unpublishing event" if unpublishing_events.blank?

      unpublishing_events.last
    end

    def next_event(event)
      next_event_index = revision_history.index(event) + 1

      raise AbortImportError, "Edition is missing next event for #{event}" unless revision_history[next_event_index]

      revision_history[next_event_index]
    end

    def edited_after_unpublishing?
      return false unless revision_history.second_to_last

      revision_history.second_to_last["state"] != "published"
    end

  private

    attr_reader :revision_history
  end
end
