class ContentRevision::ContentsValidator < ActiveModel::EachValidator
  CONTENTS_FIELDS = %w[body].freeze

  def validate_each(record, attribute, value)
    value.each do |key, content|
      unless CONTENTS_FIELDS.include?(key.to_s)
        record.errors.add(attribute, "has unknown content field ‘#{key}’", strict: true)
      end

      if key.to_s == "body" && !content.is_a?(String)
        record.errors.add(attribute, "has non-string ‘body’ field", strict: true)
      end
    end
  end
end
