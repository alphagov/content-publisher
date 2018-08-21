# frozen_string_literal: true

require 'mini_magick'

class DocumentImagesController < ApplicationController
  def edit
    @document = Document.find(params[:id])
  end

  def update
    document = Document.find(params[:id])
    upload = UploadedImageProcessorService.new(image_params[:image]).process

    if !upload.valid?
      redirect_to document_images_path(document),
                   flash: { notice: "Image upload failed", errors: upload.errors }
    else
      blob = ActiveStorage::Blob.build_after_upload(
        io: upload.file,
        content_type: upload.mime_type,
        filename: upload.filename,
      )
      blob.metadata[:width] = upload.dimensions[:width]
      blob.metadata[:height] = upload.dimensions[:height]
      blob.metadata[:crop] = upload.crop_dimensions
      blob.analyzed = true
      blob.save
      document.images.attach(blob)
      redirect_to document_images_path(document), notice: "Image attached"
    end
  end

private

  def image_params
    params.fetch(:document, {}).permit(:image)
  end

  class UploadedImageProcessorService
    InvalidImage = Struct.new(:valid?, :errors)
    ValidImage = Struct.new(
      :valid?,
      :errors,
      :file,
      :mime_type,
      :filename,
      :dimensions,
      :crop_dimensions,
    )

    OPTIMAL_WIDTH = 960
    OPTIMAL_HEIGHT = 640
    MAX_FILE_SIZE = 20.megabytes

    def initialize(upload)
      @upload = upload
    end

    def process
      errors = validate

      return invalid_image(errors) if errors.any?

      normalise_image(uploaded_image)

      valid_image(
        upload.open,
        mime_type,
        upload.original_filename,
        dimensions,
        suggested_crop,
      )
    end

  private

    attr_reader :upload

    def mime_type
      @mime_type ||= Marcel::MimeType.for(upload)
    end

    def uploaded_image
      @uploaded_image ||= MiniMagick::Image.new(upload.path)
    end

    def dimensions
      @dimensions ||= if %w[RightTop LeftBottom].include?(uploaded_image["%[orientation]"])
                        { width: uploaded_image.height, height: uploaded_image.width }
                      else
                        { width: uploaded_image.width, height: uploaded_image.height }
                      end
    end

    def validate
      return ["A file was not uploaded"] unless upload

      if %w(image/jpeg image/png image/gif).exclude?(mime_type)
        return ["Expected a jpg, png or gif image"]
      end

      errors = []

      if upload.size >= MAX_FILE_SIZE
        errors << "Image uploads must be less than 20MB in filesize"
      end

      if dimensions[:width] < OPTIMAL_WIDTH || dimensions[:height] < OPTIMAL_HEIGHT
        errors << "Images must have dimensions of at least 960 x 640 pixels"
      end

      errors
    end

    def normalise_image(image)
      rotate = degrees_to_rotate(image)
      image.combine_options do |file|
        file.rotate(rotate) unless rotate.zero?

        # remove exif data
        file.strip
      end
    end

    def degrees_to_rotate(image)
      case image["%[orientation]"]
      when "BottomRight" then 180
      when "RightTop" then 90
      when "LeftBottom" then -90
      else 0
      end
    end

    def suggested_crop
      final_aspect_ratio = OPTIMAL_HEIGHT.to_f / OPTIMAL_WIDTH.to_f
      current_aspect_ratio = dimensions[:height].to_f / dimensions[:width]
      if final_aspect_ratio > current_aspect_ratio
        # image is wide
        width = (dimensions[:height] / final_aspect_ratio).ceil
        x = ((dimensions[:width] - width) / 2).floor
        { x: x, y: 0, width: width, height: dimensions[:height] }
      elsif final_aspect_ratio < current_aspect_ratio
        # image is tall
        height = (dimensions[:width] * final_aspect_ratio).ceil
        y = ((dimensions[:height] - height) / 2).floor
        { x: 0, y: y, width: dimensions[:width], height: height }
      else
        { x: 0, y: 0, width: dimensions[:width], height: dimensions[:height] }
      end
    end

    def invalid_image(errors)
      InvalidImage.new(false, errors)
    end

    def valid_image(file, mime_type, filename, dimensions, crop_dimensions)
      ValidImage.new(
        true,
        [],
        file,
        mime_type,
        filename,
        dimensions,
        crop_dimensions,
      )
    end
  end
end
