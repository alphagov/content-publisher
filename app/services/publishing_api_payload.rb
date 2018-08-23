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
    links = document.associations["primary_publishing_organisation"].to_a +
      document.associations["organisations"].to_a
    document.associations.merge("organisations" => links.uniq)
  end

  def details
    details_hash = temporary_defaults_in_details

    document_type_schema.contents.each do |field|
      details_hash[field.id] = perform_input_type_specific_transformations(field)
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
      Govspeak::Document.new(document.contents[field.id]).to_html
    else
      document.contents[field.id]
    end
  end
end
