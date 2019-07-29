# frozen_string_literal: true

class PreviewAssetService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def put_all
    edition.image_revisions.each(&:ensure_assets)
    edition.assets.each { |asset| put(asset) }
  end

  def put(asset)
    if asset.draft?
      update(asset)
    elsif asset.absent?
      upload(asset)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  def update(asset)
    payload = Payload.new(edition).for_update
    GdsApi.asset_manager.update_asset(asset.asset_manager_id, payload)
  end

  def upload(asset)
    payload = Payload.new(edition).for_upload(asset)
    upload = GdsApi.asset_manager.create_asset(payload)
    asset.update!(file_url: upload["file_url"], state: :draft)
  end
end
