class PublishingApiPayload::History
  FIRST_CHANGE_NOTE = "First published.".freeze

  def initialize(edition)
    @edition = edition
  end

  def public_updated_at
    change_history.first&.fetch(:public_timestamp)
  end

  def first_published_at
    return edition.backdated_to if edition.backdated_to

    edition.document.first_published_at
  end

  def change_history
    change_history = edition.change_history.map do |item|
      { note: item.fetch("note"), public_timestamp: item.fetch("public_timestamp").in_time_zone }
    end

    change_history << { note: FIRST_CHANGE_NOTE,
                        public_timestamp: first_published_at || Time.zone.now }

    if edition.change_note && edition.major? && !edition.first?
      change_history << { note: edition.change_note,
                          public_timestamp: edition.published_at || Time.zone.now }
    end

    change_history.reject { |note| first_published_at && note[:public_timestamp] < first_published_at }
                  .sort_by { |note| note[:public_timestamp] }
                  .reverse
  end

private

  attr_reader :edition
end
