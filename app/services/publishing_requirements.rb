# frozen_string_literal: true

class PublishingRequirements
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def errors?
    errors.values.flatten.any?
  end

  def errors
    messages = Hash.new { |h, k| h[k] = [] }

    messages["summary"] += check_summary
    messages["change_note"] += check_change_note

    document.document_type_schema.contents.each do |field|
      messages[field.id] += check_contents(field)
    end

    messages
  end

private

  def check_contents(field)
    return [] if document.contents[field.id].present?
    [{ text: I18n.t!("publishing_requirements.no_content_#{field.id}"), href: "#content" }]
  end

  def check_summary
    return [] if document.summary.present?
    [{ text: I18n.t!("publishing_requirements.no_summary"), href: "#content" }]
  end

  def check_change_note
    return [] unless document.has_live_version_on_govuk &&
        document.update_type == "major" &&
        document.change_note.blank?

    [{ text: I18n.t!("publishing_requirements.no_change_note"), href: "#content" }]
  end
end
