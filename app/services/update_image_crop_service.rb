# frozen_string_literal: true

require "ostruct"

class UpdateImageCropService
  attr_reader :image, :params

  def initialize(image, params)
    @image = image
    @params = params
  end

  def valid?
    validator.valid?
  end

  def errors
    validator.validate
    validator.errors
  end

  def update_image
    raise RuntimeError, "Invalid crop" unless valid?

    image.update!(
      crop_x: params[:x],
      crop_y: params[:y],
      crop_width: params[:width],
      crop_height: params[:height],
    )
  end

private

  def validator
    @validator ||= CropValidator.new(params)
  end

  class CropValidator < OpenStruct
    include ActiveModel::Validations

    validates :x,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :y,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :width,
              numericality: { only_integer: true, greater_than_or_equal_to: Image::WIDTH }
    validates :height,
              numericality: { only_integer: true, greater_than_or_equal_to: Image::HEIGHT }

    validates_with ImageAspectRatioValidator
  end
end
