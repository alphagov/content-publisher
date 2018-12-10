# frozen_string_literal: true

class DocumentImagesController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    redirect_to document_images_path, alert_with_description: t("document_images.index.flashes.api_error")
  end

  def index
    @document = Document.find_by_param(params[:document_id])
  end

  def create
    @document = Document.find_by_param(params[:document_id])
    @errors = ImageUploadRequirements.new(params[:image]).errors

    if @errors.any?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("document_images.index.flashes.upload_requirements.title"),
        "items" => @errors.map { |error| { text: error } },
      }

      render :index
      return
    end

    image = ImageUploader.new(params[:image]).call(@document)
    redirect_to crop_document_image_path(params[:document_id], image.id, wizard: params[:wizard])
  end

  def crop
    @document = Document.find_by_param(params[:document_id])
    @image = @document.images.find(params[:image_id])
  end

  def update_crop
    document = Document.find_by_param(params[:document_id])
    image = Image.find(params[:image_id])

    Image.transaction do
      image.update!(update_crop_params)
      asset_manager_file_url = upload_image_to_asset_manager(image)
      delete_image_from_asset_manager(image)
      image.asset_manager_file_url = asset_manager_file_url
      image.save!
    end

    PreviewService.new(document).try_create_preview(
      user: current_user,
      type: "image_updated",
    )

    if params[:wizard].present?
      redirect_to edit_document_image_path(document, image, params.permit(:wizard))
      return
    end

    redirect_to document_images_path(document), notice: t("document_images.index.flashes.cropped", file: image.filename)
  end

  def edit
    @document = Document.find_by_param(params[:document_id])
    @image = Image.find_by(id: params[:image_id])
  end

  def update
    @document = Document.find_by_param(params[:document_id])
    @image = @document.images.find(params[:image_id])
    @image.assign_attributes(update_params)
    @issues = Requirements::ImageChecker.new(@image).pre_preview_metadata_issues

    if @issues.any?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("document_images.edit.flashes.requirements"),
        "items" => @issues.items,
      }

      render :edit
      return
    end

    @image.save!

    if params[:wizard] == "lead_image"
      @document.assign_attributes(lead_image_id: @image.id)

      PreviewService.new(@document).try_create_preview(
        user: current_user,
        type: "lead_image_updated",
      )

      redirect_to document_path(@document), notice: t("documents.show.flashes.lead_image.added", file: @image.filename)
    else
      PreviewService.new(@document).try_create_preview(
        user: current_user,
        type: "image_updated",
      )

      redirect_to document_images_path(@document), notice: t("document_images.index.flashes.details_edited", file: @image.filename)
    end
  end

  def destroy
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:image_id])
    raise "Trying to delete image for a live document" if document.has_live_version_on_govuk

    if params[:wizard] == "lead_image"
      document.assign_attributes(lead_image_id: nil)

      PreviewService.new(document).try_create_preview(
        user: current_user,
        type: "lead_image_removed",
      )
    else
      PreviewService.new(document).try_create_preview(
        user: current_user,
        type: "image_removed",
      )
    end

    AssetManagerService.new.delete(image)
    image.destroy!

    if params[:wizard] == "lead_image"
      redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.deleted", file: image.filename)
    else
      redirect_to document_images_path(document), notice: t("document_images.index.flashes.deleted", file: image.filename)
    end
  end

  def download
    image = Image.find(params[:image_id])
    variant = image.crop_variant("960x640!").processed

    send_data(
      image.blob.service.download(variant.key),
      filename: image.filename,
      type: image.content_type,
    )
  end

private

  def update_params
    params.permit(:caption, :alt_text, :credit)
  end

  def upload_image_to_asset_manager(image)
    AssetManagerService.new.upload_bytes(image, image.cropped_bytes)
  end

  def delete_image_from_asset_manager(image)
    AssetManagerService.new.delete(image)
  end

  def update_crop_params
    image_aspect_ratio = Image::HEIGHT.to_f / Image::WIDTH
    crop_height = params[:crop_width].to_i * image_aspect_ratio
    params.permit(:crop_x, :crop_y, :crop_width).merge(crop_height: crop_height.to_i)
  end
end
