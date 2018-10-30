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
        text: I18n.t("publishing_requirements.summary_presence"),
        href: "#content",
      }
    end

    @document.document_type_schema.contents.each do |field|
      if @document.contents[field.id].blank?
        messages[field.id] << {
          text: I18n.t("publishing_requirements.#{field.id}_presence"),
          href: "#content",
        }
      end
    end

    if @document.has_live_version_on_govuk &&
        @document.update_type == "major" &&
        @document.change_note.blank?
      messages["summary"] << {
        text: I18n.t("publishing_requirements.change_note_presence"),
        href: "#content",
      }
    end

    messages
  end
end
