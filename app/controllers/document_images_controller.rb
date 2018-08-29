# frozen_string_literal: true

class DocumentImagesController < ApplicationController
  def create
    document = Document.find(params[:document_id])
    upload = UploadedImageService.new(params.require(:image)).process

    if upload.valid?
      image = create_image_from_upload(upload, document)
      render json: ImageJsonPresenter.new(image).present, status: :created
    else
      render json: { errors: upload.errors }, status: :unprocessable_entity
    end
  end

private

  def create_image_from_upload(upload, document)
    blob = ActiveStorage::Blob.create_after_upload!(
      io: upload.file,
      filename: upload.filename,
      content_type: upload.mime_type,
    )

    Image.create!(
      document: document,
      blob: blob,
      filename: blob.filename,
      width: upload.dimensions[:width],
      height: upload.dimensions[:height],
      crop_x: upload.crop_dimensions[:x],
      crop_y: upload.crop_dimensions[:y],
      crop_width: upload.crop_dimensions[:width],
      crop_height: upload.crop_dimensions[:height],
    )
  end
end
