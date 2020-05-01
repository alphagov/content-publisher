require "mini_magick"

class Requirements::Form::ImageUploadChecker < Requirements::Checker
  include ActionView::Helpers::NumberHelper

  SUPPORTED_FORMATS = %w(image/jpeg image/png image/gif).freeze
  MAX_FILE_SIZE = 20.megabytes

  attr_reader :file

  def initialize(file)
    @file = file
  end

  def check
    unless file
      issues.create(:image_upload, :no_file)
      return
    end

    if unsupported_type?
      issues.create(:image_upload, :unsupported_type)
      return
    end

    if file.size >= MAX_FILE_SIZE
      issues.create(:image_upload,
                    :too_big,
                    max_size: number_to_human_size(MAX_FILE_SIZE))
    end
  end

private

  def unsupported_type?
    SUPPORTED_FORMATS.exclude?(Marcel::MimeType.for(file))
  end
end
