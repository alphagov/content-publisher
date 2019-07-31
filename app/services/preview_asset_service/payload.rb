# frozen_string_literal: true

class PreviewAssetService::Payload
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def for_update
    { draft: true,
      auth_bypass_ids: [auth_bypass_id],
      access_limited_organisation_ids: access_limited }.compact
  end

  def for_upload(asset)
    for_update.merge(file: PreviewAssetService::UploadedFile.new(asset))
  end

private

  def auth_bypass_id
    PreviewAuthBypassService.new(edition).auth_bypass_id
  end

  def access_limited
    edition.access_limit&.organisation_ids
  end
end
