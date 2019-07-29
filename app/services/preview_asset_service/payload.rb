# frozen_string_literal: true

class PreviewAssetService::Payload
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def for_update
    auth_bypass_id = PreviewAuthBypassService.new(edition).auth_bypass_id
    { draft: true, auth_bypass_ids: [auth_bypass_id] }
  end

  def for_upload(asset)
    for_update.merge(file: UploadedFile.new(asset))
  end
end
