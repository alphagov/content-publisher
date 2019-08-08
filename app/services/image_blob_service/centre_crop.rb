# frozen_string_literal: true

class ImageBlobService::CentreCrop
  attr_reader :width, :height, :desired_aspect_ratio

  def initialize(width, height, desired_aspect_ratio = nil)
    @width = width
    @height = height
    @desired_aspect_ratio = desired_aspect_ratio || default_desired_aspect_ratio
  end

  def dimensions
    aspect_ratio = width.to_f / height

    if desired_aspect_ratio < aspect_ratio
      reduced_width
    elsif desired_aspect_ratio > aspect_ratio
      reduced_height
    else
      no_changes
    end
  end

private

  def default_desired_aspect_ratio
    Image::WIDTH.to_f / Image::HEIGHT
  end

  def no_changes
    { x: 0, y: 0, width: width, height: height }
  end

  def reduced_width
    new_width = (height * desired_aspect_ratio).ceil
    x = ((width - new_width) / 2).floor
    { x: x, y: 0, width: new_width, height: height }
  end

  def reduced_height
    new_height = (width / desired_aspect_ratio).ceil
    y = ((height - new_height) / 2).floor
    { x: 0, y: y, width: width, height: new_height }
  end
end
