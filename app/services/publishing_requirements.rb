# frozen_string_literal: true

class PublishingRequirements
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def errors?(**args)
    errors(**args).values.flatten.any?
  end

  def errors(tried_to_publish: false)
    messages = Hash.new { |h, k| h[k] = [] }

    messages["summary"] += check_summary
    messages["change_note"] += check_change_note
    messages["topics"] += tried_to_publish ? check_topics : try_check_topics

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

  def try_check_topics
    check_topics
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    []
  end

  def check_topics
    return [] unless document.document_type_schema.topics
    return [] if document.topics.any?
    [{ text: I18n.t!("publishing_requirements.no_topics"), href: "#topics" }]
  end
end
