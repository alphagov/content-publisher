# frozen_string_literal: true

class PublishingApiPayload
  PUBLISHING_APP = "content-publisher"

  attr_reader :document, :document_type_schema, :publishing_metadata

  def initialize(document)
    @document = document
    @document_type_schema = document.document_type_schema
    @publishing_metadata = document_type_schema.publishing_metadata
  end

  def payload
    {
      "base_path" => document.base_path,
      "title" => document.title,
      "locale" => document.locale,
      "description" => document.summary,
      "schema_name" => publishing_metadata.schema_name,
      "document_type" => document.document_type,
      "publishing_app" => PUBLISHING_APP,
      "rendering_app" => publishing_metadata.rendering_app,
      "update_type" => document.update_type,
      "change_note" => document.change_note,
      "details" => details,
      "routes" => [
        { "path" => document.base_path, "type" => "exact" },
      ],
      "links" => links,
      "access_limited" => {
        "auth_bypass_ids" => [DocumentUrl.new(document).auth_bypass_id],
      },
    }
  end

private

  def links
    links = document.tags["primary_publishing_organisation"].to_a +
      document.tags["organisations"].to_a

    document.tags.merge("organisations" => links.uniq)
  end

  def image
    {
      "url" => document.lead_image.asset_manager_file_url,
      "alt_text" => document.lead_image.alt_text,
      "caption" => document.lead_image.caption,
    }
  end

  def details
    details_hash = temporary_defaults_in_details

    document_type_schema.contents.each do |field|
      details_hash[field.id] = perform_input_type_specific_transformations(field)
    end

    if document_type_schema.lead_image && document.lead_image.present?
      details_hash["image"] = image
    end

    details_hash
  end

  def temporary_defaults_in_details
    {
      "government" => {
        "title" => "Hey", "slug" => "what", "current" => true
      },
      "change_history" => [
        {
          "public_timestamp" => Time.now.iso8601,
          "note" => "To support email alerts",
        },
      ],
      "political" => false,
    }
  end

  # Note: once this grows to a sufficient size, move it over into a new class
  # or class system.
  def perform_input_type_specific_transformations(field)
    if field.type == "govspeak"
      GovspeakService.new.to_html(document.contents[field.id])
    else
      document.contents[field.id]
    end
  end
end
