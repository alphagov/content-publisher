# frozen_string_literal: true

class ContentValidator
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def validation_messages
    messages = []

    document.document_type_schema.validations.each do |schema|
      messages += send("validate_#{schema.type}", schema)
    end

    messages
  end

private

  def validate_min_length(schema)
    size = document.contents[schema.id].to_s.size
    return [] unless size < schema.settings["limit"]
    [schema.message]
  end

  def validate_title_min_length(schema)
    size = document.title.to_s.size
    return [] unless size < schema.settings["limit"]
    [schema.message]
  end

  def validate_summary_min_length(schema)
    size = document.title.to_s.size
    return [] unless size < schema.settings["limit"]
    [schema.message]
  end
end
