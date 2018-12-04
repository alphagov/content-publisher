# frozen_string_literal: true

require "mini_magick"

class ImageUploadRequirements
  include ActionView::Helpers::NumberHelper

  SUPPORTED_FORMATS = %w(image/jpeg image/png image/gif).freeze
  MAX_FILE_SIZE = 20.megabytes

  attr_reader :file

  def initialize(file)
    @file = file
  end

  def errors
    messages = []

    unless file
      return [I18n.t!("document_images.index.flashes.upload_requirements.no_file_selected")]
    end

    if SUPPORTED_FORMATS.exclude?(Marcel::MimeType.for(file)) || animated_image?
      return [I18n.t!("document_images.index.flashes.upload_requirements.invalid_format")]
    end

    if file.size >= MAX_FILE_SIZE
      messages << I18n.t!("document_images.index.flashes.upload_requirements.max_size",
                         max_size: number_to_human_size(MAX_FILE_SIZE))
    end

    dimensions = ImageNormaliser.new(file.path).dimensions

    if dimensions[:width] < Image::WIDTH || dimensions[:height] < Image::HEIGHT
      messages << I18n.t!("document_images.index.flashes.upload_requirements.min_dimensions",
                         width: Image::WIDTH,
                         height: Image::HEIGHT)
    end

    messages
  end

private

  def animated_image?
    MiniMagick::Image.new(file.tempfile.path).frames.count > 1
  end
end
