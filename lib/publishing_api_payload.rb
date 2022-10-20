class PublishingApiPayload
  PUBLISHING_APP = "content-publisher".freeze

  attr_reader :edition, :document_type, :publishing_metadata, :republish

  def initialize(edition, republish: false)
    @edition = edition
    @document_type = edition.document_type
    @publishing_metadata = document_type.publishing_metadata
    @republish = republish
  end

  def payload
    payload = {
      locale: edition.locale,
      schema_name: publishing_metadata.schema_name,
      document_type: document_type.id,
      publishing_app: PUBLISHING_APP,
      rendering_app: publishing_metadata.rendering_app,
      update_type: edition.update_type,
      details:,
      links:,
      access_limited:,
      auth_bypass_ids: [edition.auth_bypass_id],
      public_updated_at: history.public_updated_at,
    }
    payload[:first_published_at] = history.first_published_at if history.first_published_at.present?

    fields = document_type.contents + document_type.tags
    fields.each { |f| payload.deep_merge!(f.payload(edition)) }

    if republish
      payload[:update_type] = "republish"
      payload[:bulk_publishing] = true
    end

    payload
  end

private

  def history
    @history ||= History.new(edition)
  end

  def access_limited
    return {} unless edition.access_limit

    { organisations: edition.access_limit_organisation_ids }
  end

  def links
    { government: [edition.government&.content_id].compact }
  end

  def image
    {
      high_resolution_url: edition.lead_image_revision.asset_url("high_resolution"),
      url: edition.lead_image_revision.asset_url("300"),
      alt_text: edition.lead_image_revision.alt_text,
      caption: edition.lead_image_revision.caption,
      credit: edition.lead_image_revision.credit,
    }.compact
  end

  def details
    details = {
      political: edition.political?,
      change_history: history.change_history,
      attachments:,
    }

    if document_type.lead_image? && edition.lead_image_revision.present?
      details[:image] = image
    end

    details[:documents] = [] if document_type.attachments.featured?

    details
  end

  def publication?
    publishing_metadata.schema_name == "publication"
  end

  def attachments
    file_attachments = edition.file_attachment_revisions

    file_attachments.map do |attachment|
      FileAttachmentPayload.new(attachment, edition).payload
    end
  end
end
