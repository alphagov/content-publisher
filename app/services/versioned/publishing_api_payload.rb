# frozen_string_literal: true

module Versioned
  class PublishingApiPayload
    PUBLISHING_APP = "content-publisher"

    attr_reader :edition, :document_type, :publishing_metadata

    def initialize(edition)
      @edition = edition
      @document_type = edition.document_type
      @publishing_metadata = document_type.publishing_metadata
    end

    def payload
      payload = {
        "base_path" => edition.base_path,
        "title" => edition.title,
        "locale" => edition.locale,
        "description" => edition.summary,
        "schema_name" => publishing_metadata.schema_name,
        "document_type" => document_type.id,
        "publishing_app" => PUBLISHING_APP,
        "rendering_app" => publishing_metadata.rendering_app,
        "update_type" => edition.update_type,
        "details" => details,
        "routes" => [
          { "path" => edition.base_path, "type" => "exact" },
        ],
        "links" => links,
        "access_limited" => {
          "auth_bypass_ids" => [Versioned::EditionUrl.new(edition).auth_bypass_id],
        },
      }
      payload["change_note"] = edition.change_note if major_update?
      payload
    end

  private

    def links
      links = edition.tags["primary_publishing_organisation"].to_a +
        edition.tags["organisations"].to_a

      role_appointments = edition.tags["role_appointments"]
      edition.tags
        .except("role_appointments")
        .merge(roles_and_people(role_appointments))
        .merge("organisations" => links.uniq)
    end

    def image
      {
        "url" => edition.lead_image.asset_manager_file_url,
        "alt_text" => edition.lead_image.alt_text,
        "caption" => edition.lead_image.caption,
        "credit" => edition.lead_image.credit,
      }
    end

    def details
      details = {}

      document_type.contents.each do |field|
        details[field.id] = perform_input_type_specific_transformations(field)
      end

      if document_type.lead_image && edition.lead_image.present?
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
        GovspeakDocument.new(edition.contents[field.id]).to_html
      else
        document.contents[field.id]
      end
    end

    def major_update?
      edition.update_type == "major"
    end
  end
end
