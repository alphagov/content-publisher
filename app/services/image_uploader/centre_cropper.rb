# frozen_string_literal: true

class ImageUploader::CentreCropper
  attr_reader :width, :height, :aspect_ratio, :desired_aspect_ratio

  def initialize(width, height, desired_aspect_ratio)
    @width = width
    @height = height
    @aspect_ratio = width.to_f / height
    @desired_aspect_ratio = desired_aspect_ratio
  end

  def dimensions
    @dimensions ||= if desired_aspect_ratio < aspect_ratio
                      reduce_width
                    elsif desired_aspect_ratio > aspect_ratio
                      reduce_height
                    else
                      no_changes
                    end
  end

private

  def no_changes
    { x: 0, y: 0, width: width, height: height }
  end

  def reduce_width
    new_width = (height * desired_aspect_ratio).ceil
    x = ((width - new_width) / 2).floor
    { x: x, y: 0, width: new_width, height: height }
  end

  def reduce_height
    new_height = (width / desired_aspect_ratio).ceil
    y = ((height - new_height) / 2).floor
    { x: 0, y: y, width: width, height: new_height }
  end
end
