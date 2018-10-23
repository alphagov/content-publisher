# frozen_string_literal: true

# Determines whether content should be published to the publishing-api
class PublishingRequirements
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def errors
    messages = Hash.new { |h, k| h[k] = [] }

    if @document.summary.blank?
      messages["summary"] << {
        text: I18n.t("publishing_requirements.presence", field: "summary"),
        href: "#content",
      }
    end

    @document.document_type_schema.contents.each do |field|
      if @document.contents[field.id].blank?
        messages[field.id] << {
          text: I18n.t("publishing_requirements.field_presence", field: field.label.downcase),
          href: "#content",
        }
      end
    end

    messages
  end
end
