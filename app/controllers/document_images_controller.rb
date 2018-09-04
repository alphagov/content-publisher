# frozen_string_literal: true

class DocumentImagesController < ApplicationController
  def create
    document = Document.find_by_param(params[:document_id])
    upload = UploadedImageService.new(params.require(:image)).process

    if upload.valid?
      image = create_image_from_upload(upload, document)
      render json: ImageJsonPresenter.new(image).present, status: :created
    else
      render json: { errors: upload.errors }, status: :unprocessable_entity
    end
  end

  def update
    document = Document.find_by_param(params[:document_id])
    image = Image.find_by!(id: params[:id], document_id: document.id)
    image.assign_attributes(image_params)

    if image.valid?
      image.save
      render json: ImageJsonPresenter.new(image).present, status: :ok
    else
      render json: { errors: image.errors }, status: :unprocessable_entity
    end
  end

private

  def image_params
    params.require(:image).permit(
      :crop_x,
      :crop_y,
      :crop_width,
      :crop_height,
    )
  end

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
