# frozen_string_literal: true

require "gds_api/asset_manager"

class AssetManagerService
  def self.upload(image_variant)
    processed_variant = image_variant.processed
    path = "tmp/#{image_variant.blob.filename}"
    File.open(path, 'wb') do |f|
      f.write(processed_variant.service.download(processed_variant.key))
      f.rewind
      asset_manager.create_asset(file: f)
    end
    FileUtils.rm(path)
  rescue GdsApi::BaseError => e
    false
  end

  def self.asset_manager
    GdsApi::AssetManager.new(Plek.new.find("asset-manager"))
  end

  private_class_method :asset_manager
end
