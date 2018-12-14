# frozen_string_literal: true

class ImageUpdateService
  CROP_ATTRIBUTES = %w[crop_x crop_y crop_width crop_height].freeze

  attr_reader :image

  def initialize(image)
    @image = image
  end

  def call
    if image.publication_state == "live"
      raise "Cannot edit live images"
    end

    if need_to_update_asset_manager?
      asset_manager_file_url = upload_to_asset_manager(image)
      AssetManagerService.new.delete(image)
      image.asset_manager_file_url = asset_manager_file_url
      image.publication_state = "draft"
    end

    image.save!
  end

private

  def upload_to_asset_manager(image)
    AssetManagerService.new.upload_bytes(image, image.cropped_bytes)
  end

  def need_to_update_asset_manager?
    (image.changed_attributes.keys & CROP_ATTRIBUTES).any?
  end
end
