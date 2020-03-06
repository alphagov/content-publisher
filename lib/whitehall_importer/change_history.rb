module WhitehallImporter
  class ChangeHistory
    attr_reader :entries

    def initialize(whitehall_export)
      @entries = build_entries(whitehall_export["editions"])
    end

    def for(edition_number)
      entries.each_with_object([]) do |item, change_history|
        change_history << item["change_history_entry"] if item["edition_number"] < edition_number
      end
    end

  private

    def build_entries(editions)
      change_history_entries = editions.map.with_index do |edition, index|
        edition_number = index + 1

        next if edition["minor_change"] || edition_number == 1
        next if edition_hasnt_been_published?(edition)

        history_event(edition, edition_number)
      end

      change_history_entries.compact.reverse
    end

    def edition_hasnt_been_published?(edition)
      %w[submitted rejected draft].include?(edition["state"]) && edition["unpublishing"].blank?
    end

    def history_event(edition, edition_number)
      publish_event = EditionHistory.new(edition["revision_history"]).last_state_event("published")

      raise AbortImportError, "Edition has a major change but no change note" if edition["change_note"].blank?
      raise AbortImportError, "Edition has a major change but no publish event" if publish_event.blank?

      {
        "edition_number" => edition_number,
        "change_history_entry" => {
          "id" => SecureRandom.uuid,
          "note" => edition["change_note"],
          "public_timestamp" => publish_event["created_at"],
        },
      }
    end
  end
end
