# frozen_string_literal: true

module WhitehallImporter
  class EditionHistory
    def initialize(revision_history)
      @revision_history = revision_history
    end

    def last_state_event(state)
      revision_history.select { |h| h["state"] == state }.last
    end

    def last_state_event!(state)
      last_state_event(state) || raise(AbortImportError, "Edition is missing a #{state} event")
    end

    def next_event(event)
      index = revision_history.index(event)
      return unless index

      revision_history[index + 1]
    end

    def next_event!(event)
      next_event(event) || (raise AbortImportError, "Edition is missing next event for #{event}")
    end

    def create_event
      revision_history.select { |h| h["event"] == "create" }.first
    end

    def create_event!
      create_event || (raise AbortImportError, "Edition is missing a create event")
    end

    def last_unpublishing_event
      # we can determine the event that marks an unpublishing by a draft event following a published event
      unpublishing_events = revision_history.select.with_index do |item, index|
        next unless item["state"] == "draft"

        previous_entry = revision_history[index - 1]
        previous_entry && previous_entry["state"] == "published"
      end

      unpublishing_events.last
    end

    def last_unpublishing_event!
      last_unpublishing_event || (raise AbortImportError, "Edition is missing unpublishing event")
    end

    def edited_after_unpublishing?
      unpublishing_event = last_unpublishing_event
      return false unless unpublishing_event

      revision_history.last != unpublishing_event
    end

    def editors
      revision_history.pluck("whodunnit").uniq
    end

  private

    attr_reader :revision_history
  end
end
