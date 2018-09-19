# frozen_string_literal: true

class DocumentImagesController < ApplicationController
  def create
    document = Document.find_by_param(params[:document_id])
    image_uploader = ImageUploader.new(params.require(:image))

    unless image_uploader.valid?
      render json: { errors: image_uploader.errors }, status: :unprocessable_entity
      return
    end

    begin
      image = image_uploader.upload(document)
      image.asset_manager_file_url = upload_image_to_asset_manager(image)
    rescue GdsApi::BaseError
      render json: { errors: "Asset manager upload error" }, status: :unprocessable_entity
      return
    end
    image.save!
    render json: ImageJsonPresenter.new(image).present, status: :created
  end

  def update
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:id])
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

  def upload_image_to_asset_manager(image)
    AssetManagerService.new.upload(image.cropped_file)
  end
end
