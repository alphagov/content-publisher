# frozen_string_literal: true

class PreviewAssetService < ApplicationService
  def initialize(edition, asset)
    @edition = edition
    @asset = asset
  end

  def call
    if asset.draft?
      update_asset(asset)
    elsif asset.absent?
      upload_asset(asset)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  attr_reader :edition, :asset

  def update_asset(asset)
    payload = Payload.new(edition).for_update
    GdsApi.asset_manager.update_asset(asset.asset_manager_id, payload)
  end

  def upload_asset(asset)
    payload = Payload.new(edition).for_upload(asset)
    upload = GdsApi.asset_manager.create_asset(payload)
    asset.update!(file_url: upload["file_url"], state: :draft)
  end
end
