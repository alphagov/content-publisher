# frozen_string_literal: true

class ImageJsonPresenter
  include Rails.application.routes.url_helpers

  attr_reader :image

  def initialize(image)
    @image = image
  end

  def present
    # If we don't specify only_path in these path calls we receieve an argument
    # error due to host not being in default url options, even though we're
    # not creeating ab absolute url
    {
      id: image.id,
      filename: image.filename,
      original: {
        path: rails_blob_path(image.blob, only_path: true),
        dimensions: { width: image.width, height: image.height },
      },
      crop: {
        path: rails_representation_path(image.crop_variant, only_path: true),
        dimensions: { width: image.crop_width, height: image.crop_height },
        offset: { x: image.crop_x, y: image.crop_y },
      },
    }
  end
end
