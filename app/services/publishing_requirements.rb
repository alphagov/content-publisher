# frozen_string_literal: true

# Determines whether content should be published to the publishing-api
class PublishingRequirements
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def ready_for_publishing?
    unfulfilled_publishing_requirements.empty?
  end

  def unfulfilled_publishing_requirements
    @unfulfilled_publishing_requirements ||= begin
      messages = []
      perform_validations_that_apply_to_all_formats(messages)
      perform_format_specific_validations(messages)
      messages
    end
  end

private

  def perform_validations_that_apply_to_all_formats(messages)
    if document.title.to_s.size < 10
      messages << [I18n.t("publishing_requirements.title"), "#content"]
    end

    if document.summary.to_s.size < 10
      messages << [I18n.t("publishing_requirements.summary"), "#content"]
    end
  end

  def perform_format_specific_validations(messages)
    schema = document.document_type_schema

    schema.contents.each do |field|
      # Validations come in pairs, like `min_length: 10`. They should use
      # a underscored version of JSON Schema's validation system. For example,
      # `max_length`, `one_of`.
      #
      # http://json-schema.org/latest/json-schema-validation.html
      field.validations.each do |validation_name, value|
        case validation_name
        when "min_length"
          if document.contents[field.id].to_s.size < value
            messages << [I18n.t("publishing_requirements.min_length", field: field.label.downcase, min_length: value), "#content"]
          end
        end
      end
    end
  end
end
