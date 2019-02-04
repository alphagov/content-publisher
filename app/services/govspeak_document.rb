# frozen_string_literal: true

class GovspeakDocument
  include Rails.application.routes.url_helpers

  attr_reader :text

  def initialize(text, edition)
    @text = text
    @edition = edition
  end

  def in_app_html
    Govspeak::Document.new(text, contacts: contacts, images: in_app_images).to_html
  end

  def payload_html
    Govspeak::Document.new(text, contacts: contacts, images: payload_images).to_html
  end

private

  def in_app_images
    @edition.revision.image_revisions.map do |image_revision|
      image_attributes(image_revision).merge(
        # This is the same as url_for(image_revision.crop_variant) in the view, or
        # image_revision.crop_variant.service_url, except that these don't work outside
        # of a request context which normally includes the request host.
        url: rails_representation_path(image_revision.crop_variant, only_path: true)
      )
    end
  end

  def payload_images
    @edition.revision.image_revisions.map do |image_revision|
      image_attributes(image_revision).merge(url: image_revision.asset_url("960"))
    end
  end

  def image_attributes(image_revision)
    {
      alt_text: image_revision.alt_text,
      caption: image_revision.caption,
      credit: image_revision.credit,
      id: image_revision.filename
    }
  end

  def contacts
    @contacts ||= begin
                    contact_content_ids = Govspeak::Document.new(text).extract_contact_content_ids
                    contacts = contact_content_ids.map do |id|
                      ContactsService.new.by_content_id(id)
                    end
                    contacts.compact
                  end
  end


end
