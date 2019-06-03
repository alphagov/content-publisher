# frozen_string_literal: true

class GovspeakDocument::PayloadOptions < GovspeakDocument::Options
  include Rails.application.routes.url_helpers
  include FileAttachmentHelper

  attr_reader :text, :edition

  def to_h
    super.merge(
      images: payload_images,
      attachments: payload_attachments,
    )
  end

private

  def payload_images
    edition.revision.image_revisions.map(&method(:image_attributes))
  end

  def payload_attachments
    edition.file_attachment_revisions.map(&method(:attachment_attributes))
  end

  def image_attributes(image_revision)
    {
      url: image_revision.asset_url("960"),
      alt_text: image_revision.alt_text,
      caption: image_revision.caption,
      credit: image_revision.credit,
      id: image_revision.filename,
    }
  end

  def attachment_attributes(attachment_revision)
    alt_email = OrganisationService.new(edition).alternative_format_contact_email
    attributes = file_attachment_attributes(attachment_revision, edition.document)

    attributes.merge(
      url: attachment_revision.asset_url,
      alternative_format_contact_email: alt_email,
    )
  end
end
