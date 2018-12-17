# frozen_string_literal: true

class PublishingApiPayload
  PUBLISHING_APP = "content-publisher"

  attr_reader :document, :document_type, :publishing_metadata

  def initialize(document)
    @document = document
    @document_type = document.document_type
    @publishing_metadata = document_type.publishing_metadata
  end

  def payload
    payload = {
      "base_path" => document.base_path,
      "title" => document.title,
      "locale" => document.locale,
      "description" => document.summary,
      "schema_name" => publishing_metadata.schema_name,
      "document_type" => document.document_type_id,
      "publishing_app" => PUBLISHING_APP,
      "rendering_app" => publishing_metadata.rendering_app,
      "update_type" => document.update_type,
      "details" => details,
      "routes" => [
        { "path" => document.base_path, "type" => "exact" },
      ],
      "links" => links,
      "access_limited" => {
        "auth_bypass_ids" => [DocumentUrl.new(document).auth_bypass_id],
      },
    }
    payload["change_note"] = document.change_note if major_update?
    payload
  end

private

  def links
    links = document.tags["primary_publishing_organisation"].to_a +
      document.tags["organisations"].to_a

    role_appointments = document.tags["role_appointments"]
    document.tags
      .except("role_appointments")
      .merge(roles_and_people(role_appointments))
      .merge("organisations" => links.uniq)
  end

  def image
    {
      "url" => document.lead_image.asset_manager_file_url,
      "alt_text" => document.lead_image.alt_text,
      "caption" => document.lead_image.caption,
      "credit" => document.lead_image.credit,
    }
  end

  def details
    details = {}

    document_type.contents.each do |field|
      details[field.id] = perform_input_type_specific_transformations(field)
    end

    if document_type.lead_image && document.lead_image.present?
      details["image"] = image
    end

    details
  end

  def roles_and_people(role_appointments)
    return {} if !role_appointments || role_appointments.count.zero?

    role_appointments
      .each_with_object("roles" => [], "people" => []) do |appointment_id, memo|
        response = GdsApi.publishing_api_v2.get_links(appointment_id).to_hash

        roles = response.dig("links", "role") || []
        people = response.dig("links", "person") || []

        memo["roles"] = (memo["roles"] + roles).uniq
        memo["people"] = (memo["people"] + people).uniq
      end
  end

  # Note: once this grows to a sufficient size, move it over into a new class
  # or class system.
  def perform_input_type_specific_transformations(field)
    if field.type == "govspeak"
      GovspeakDocument.new(document.contents[field.id]).to_html
    else
      document.contents[field.id]
    end
  end

  def major_update?
    document.update_type == "major"
  end
end
