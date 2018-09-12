# frozen_string_literal: true

class DocumentImagesController < ApplicationController
  def create
    document = Document.find_by_param(params[:document_id])
    image_uploader = ImageUploader.new(params.require(:image))

    if image_uploader.valid?
      image = image_uploader.upload(document)
      render json: ImageJsonPresenter.new(image).present, status: :created
    else
      render json: { errors: image_uploader.errors }, status: :unprocessable_entity
    end
  end

  def update
    document = Document.find_by_param(params[:document_id])
    image = Image.find_by!(id: params[:id], document_id: document.id)
    image.assign_attributes(image_params)

    if image.valid?
      image.save!
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
end
