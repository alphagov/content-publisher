class ImageUpdateService
  attr_reader :image

  CROP_ATTRIBUTES = %w[crop_x crop_y crop_width crop_height]

  def initialize(image)
    @image = image
  end

  def call
    if need_to_update_asset_manager?
      asset_manager_file_url = upload_to_asset_manager(image)
      AssetManagerService.new.delete(image)
      image.asset_manager_file_url = asset_manager_file_url
      image.publication_state = "sent_to_draft"
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
