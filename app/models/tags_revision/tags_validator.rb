class TagsRevision::TagsValidator < ActiveModel::EachValidator
  UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\Z/

  TAG_FIELDS = %w[primary_publishing_organisation
                  organisations
                  world_locations
                  role_appointments
                  topical_events].freeze

  def validate_each(record, attribute, value)
    value.each do |key, tags|
      unless TAG_FIELDS.include?(key.to_s)
        record.errors.add(attribute, "has unknown tag field ‘#{key}’", strict: true)
      end

      unless tags.is_a? Array
        record.errors.add(attribute, "has non-array field ‘#{key}’", strict: true)
      end

      tags.each do |tag|
        unless UUID_REGEX.match?(tag)
          record.errors.add(attribute, "has an invalid tag ID ‘#{tag}’", strict: true)
        end
      end
    end
  end
end
