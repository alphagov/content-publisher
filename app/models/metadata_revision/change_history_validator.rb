class MetadataRevision::ChangeHistoryValidator < ActiveModel::EachValidator
  UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\Z/.freeze

  def validate_each(record, attribute, value)
    previous_time = nil

    value.each do |change_note|
      unless change_note.keys.sort == %w(id note public_timestamp)
        record.errors.add(attribute, "has an entry with invalid keys", strict: true)
      end

      unless change_note["id"].match?(UUID_REGEX)
        record.errors.add(attribute, "has an entry with a non UUID id", strict: true)
      end

      begin
        time = Time.zone.rfc3339(change_note["public_timestamp"])
      rescue ArgumentError
        record.errors.add(attribute, "has an entry with an invalid timestamp", strict: true)
      end

      if previous_time && previous_time < time
        record.errors.add(attribute, "is not in a reverse chronological ordering", strict: true)
      end

      previous_time = time
    end
  end
end
