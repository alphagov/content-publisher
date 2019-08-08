# frozen_string_literal: true

require "mini_magick"

class ImageNormaliser
  attr_reader :issues, :raw_file

  def initialize(raw_file)
    @raw_file = raw_file
  end

  def normalise
    @issues = Requirements::CheckerIssues.new
    check_image_is_not_animated
    check_image_is_big_enough
    normalised_image if issues.none?
  end

private

  def normalised_image
    @normalised_image ||= TempImage.new(raw_file)
  end

  def check_image_is_big_enough
    return unless normalised_image.width < Image::WIDTH ||
      normalised_image.height < Image::HEIGHT

    issues << Requirements::Issue.new(:image_upload,
                                      :too_small,
                                      width: Image::WIDTH,
                                      height: Image::HEIGHT)
  end

  def check_image_is_not_animated
    return unless normalised_image.frames.count > 1

    issues << Requirements::Issue.new(:image_upload, :animated_image)
  end
end
