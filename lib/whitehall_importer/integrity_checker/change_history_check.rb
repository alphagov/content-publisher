module WhitehallImporter
  class IntegrityChecker::ChangeHistoryCheck
    attr_reader :edition, :proposed_change_history, :publishing_api_change_history

    def initialize(edition, proposed_change_history, publishing_api_change_history)
      @edition = edition
      @proposed_change_history = trim_proposed_change_history(proposed_change_history)
      @publishing_api_change_history = publishing_api_change_history
    end

    def match?
      if publishing_api_change_history.empty? && edition.live?
        return proposed_history_has_first_published_change_note?
      end

      return false unless history_length_matches?

      history_matches?(proposed_change_history, publishing_api_change_history)
    end

  private

    def trim_proposed_change_history(proposed_change_history)
      first_non_live_edition = !edition.live? && edition.first?
      major_non_live_edition = edition.major? && edition.change_note && !edition.live?

      if first_non_live_edition || major_non_live_edition
        proposed_change_history.drop(1)
      else
        proposed_change_history
      end
    end

    def history_length_matches?
      proposed_change_history.length == publishing_api_change_history.length
    end

    def history_matches?(proposed, publishing_api)
      proposed.zip(publishing_api).all? do |proposed_history, publishing_api_history|
        proposed_time = proposed_history["public_timestamp"]
        publishing_api_time = publishing_api_history["public_timestamp"]

        seconds_difference = proposed_history["note"] == "First published." ? 60 : 5

        proposed_history["note"] == publishing_api_history["note"] &&
          IntegrityChecker.time_matches?(proposed_time, publishing_api_time, seconds_difference)
      end
    end

    def proposed_history_has_first_published_change_note?
      proposed_change_history.one? &&
        proposed_change_history.first["note"] == PublishingApiPayload::History::FIRST_CHANGE_NOTE
    end
  end
end
