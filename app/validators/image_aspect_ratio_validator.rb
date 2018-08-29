# frozen_string_literal: true

class ImageAspectRatioValidator < ActiveModel::Validator
  def validate(record)
    return unless sane_input(record.width, record.height)

    unless valid_aspect_ratio?(record.width.to_i, record.height.to_i)
      record.errors[:base] << error_message
    end
  end

private

  def sane_input(width, height)
    width.to_i.to_s == width.to_s && height.to_i.to_s == height.to_s
  end

  def valid_aspect_ratio?(width, height)
    valid_width, valid_height = valid_dimensions
    aspect_ratio = valid_width.to_f / valid_height

    allowed_dimensions(width, height, aspect_ratio).include?([width, height])
  end

  def allowed_dimensions(actual_width, actual_height, aspect_ratio)
    allowed_height = actual_width / aspect_ratio
    allowed_width = actual_height * aspect_ratio

    # We're being forgiving here to accept both whole numbers if aspect ratio
    # creates a fraction
    [
      [actual_width, allowed_height.ceil],
      [actual_width, allowed_height.floor],
      [allowed_width.ceil, actual_height],
      [allowed_width.floor, actual_height],
    ].uniq
  end

  def error_message
    # This is used to get simplest ratio for dimensions.
    # E.g. Rational(1920, 1080) => (16/9)
    ratio = Rational(*valid_dimensions)

    I18n.t(
      "validations.images.aspect_ratio",
      aspect_ratio: "#{ratio.numerator}:#{ratio.denominator}",
    )
  end

  def valid_dimensions
    [Image::WIDTH, Image::HEIGHT]
  end
end
