# frozen_string_literal: true

# Determines whether content should be drafted
class DraftingRequirements
  attr_reader :document

  TITLE_MAX_LENGTH = 150

  def initialize(document)
    @document = document
  end

  def errors
    messages = Hash.new { |hsh, key| hsh[key] = [] }

    if document.title.blank?
      messages["title"] << I18n.t("documents.edit.flashes.drafting_requirements.title_missing",
                                  field: "title")
    end

    if document.title.size > TITLE_MAX_LENGTH
      messages["title"] << I18n.t("documents.edit.flashes.drafting_requirements.title_max_length",
                                  max_length: TITLE_MAX_LENGTH)
    end

    if document.title.lines.count > 1
      messages["title"] << I18n.t("documents.edit.flashes.drafting_requirements.title_multiple_lines",
                                  field: "title")
    end

    messages
  end
end
