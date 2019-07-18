# frozen_string_literal: true

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
      "locale" => edition.locale,
      "schema_name" => publishing_metadata.schema_name,
      "document_type" => document_type.id,
      "publishing_app" => PUBLISHING_APP,
      "rendering_app" => publishing_metadata.rendering_app,
      "update_type" => edition.update_type,
      "details" => {},
      "links" => links,
      "access_limited" => {
        "auth_bypass_ids" => [
          PreviewAuthBypassService.new(edition).auth_bypass_id,
        ],
      },
    }

    payload["change_note"] = edition.change_note if edition.major?
    inject_fields(payload)

    if edition.backdated_to.present?
      payload["first_published_at"] = edition.backdated_to
      payload["public_updated_at"] = edition.backdated_to if edition.first?
    end

    payload
  end

  def intent_payload
    raise "Edition must be scheduled to create an intent" unless edition.scheduled?

    scheduling = edition.status.details
    rendering_app = publishing_metadata.rendering_app

    {
      publish_time: scheduling.publish_time,
      publishing_app: PUBLISHING_APP,
      rendering_app: rendering_app,
    }
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
      "high_resolution_url" => edition.lead_image_revision.asset_url("high_resolution"),
      "url" => edition.lead_image_revision.asset_url("300"),
      "alt_text" => edition.lead_image_revision.alt_text,
      "caption" => edition.lead_image_revision.caption,
      "credit" => edition.lead_image_revision.credit,
    }
  end

  def inject_fields(payload)
    document_type.contents.each do |field|
      field.inject(edition, payload)
    end

    if document_type.images && edition.lead_image_revision.present?
      payload["details"]["image"] = image
    end
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
end
