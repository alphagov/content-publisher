# frozen_string_literal: true

# Determines whether content should be published to the publishing-api
class ContentValidator
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def validation_messages
    messages = []
    perform_validations_that_apply_to_all_formats(messages)
    perform_format_specific_validations(messages)
    messages
  end

private

  def perform_validations_that_apply_to_all_formats(messages)
    if document.title.to_s.size < 10
      # TODO: extract string into locale file
      messages << "The title needs to be at least 10 characters long"
    end

    if document.summary.to_s.size < 10
      # TODO: extract string into locale file
      messages << "The summary needs to be at least 10 characters long"
    end
  end

  def perform_format_specific_validations(messages)
    schema = document.document_type_schema

    schema.fields.each do |field|
      # Validations come in pairs, like `min_length: 10`. They should use
      # a underscored version of JSON Schema's validation system. For example,
      # `max_length`, `one_of`.
      #
      # http://json-schema.org/latest/json-schema-validation.html
      field.validations.each do |validation_name, value|
        case validation_name
        when "min_length"
          if document.contents[field.id].to_s.size < value
            # TODO: extract string into locale file
            messages << "#{field.label} needs to be at least #{value} characters long"
          end
        end
      end
    end
  end
end
