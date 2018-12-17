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
      AssetManagerService.new.update_bytes(image, image.cropped_bytes)
    end

    image.save!
  end

private

  def need_to_update_asset_manager?
    (image.changed_attributes.keys & CROP_ATTRIBUTES).any?
  end
end
