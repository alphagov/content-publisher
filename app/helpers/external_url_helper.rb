# frozen_string_literal: true

module ExternalUrlHelper
  def edition_public_url(edition)
    return unless edition.base_path

    Plek.new.website_root + edition.base_path
  end

  def edition_preview_url(edition)
    return unless edition.base_path

    service = PreviewAuthBypassService.new(edition.document)
    params = { token: service.preview_token }.to_query
    draft_host_url + edition.base_path + "?" + params
  end

  def draft_host_url
    Plek.new.external_url_for("draft-origin")
  end
end
