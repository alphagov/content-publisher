module WhitehallImporter
  class IntegrityChecker::ChangeHistoryCheck
    attr_reader :live_edition, :proposed_change_history, :publishing_api_change_history

    def initialize(proposed_change_history, publishing_api_change_history, live_edition:)
      @proposed_change_history = proposed_change_history
      @publishing_api_change_history = publishing_api_change_history
      @live_edition = live_edition
    end

    def match?
      return false unless history_length_matches?

      if live_edition
        history_matches?(proposed_change_history, publishing_api_change_history)
      else
        history_excluding_first_timestamp_matches?
      end
    end

  private

    def history_length_matches?
      proposed_change_history.length == publishing_api_change_history.length
    end

    def history_matches?(proposed, publishing_api)
      proposed.zip(publishing_api).all? do |proposed_history, publishing_api_history|
        proposed_time = proposed_history["public_timestamp"]
        publishing_api_time = publishing_api_history["public_timestamp"]

        proposed_history["note"] == publishing_api_history["note"] &&
          IntegrityChecker.time_matches?(proposed_time, publishing_api_time)
      end
    end

    def history_excluding_first_timestamp_matches?
      proposed_head, *proposed_tail = proposed_change_history
      publishing_api_head, *publishing_api_tail = publishing_api_change_history

      first_note_matches = proposed_head["note"] == publishing_api_head["note"]
      remaining_history_matches = history_matches?(proposed_tail, publishing_api_tail)

      first_note_matches && remaining_history_matches
    end
  end
end
