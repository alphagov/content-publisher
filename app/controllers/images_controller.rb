# frozen_string_literal: true

class ImagesController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    redirect_to images_path, alert_with_description: t("images.index.flashes.api_error")
  end

  def index
    @document = Document.find_by_param(params[:document_id])
  end

  def create
    @document = Document.find_by_param(params[:document_id])
    @issues = Requirements::ImageUploadChecker.new(params[:image]).issues

    if @issues.any?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("images.index.flashes.upload_requirements"),
        "items" => @issues.items,
      }

      render :index
      return
    end

    image = ImageUploadService.new(@document, params[:image]).call
    redirect_to crop_image_path(params[:document_id], image.id, wizard: params[:wizard])
  end

  def crop
    @document = Document.find_by_param(params[:document_id])
    @image = @document.images.find(params[:image_id])
  end

  def update_crop
    document = Document.find_by_param(params[:document_id])
    image = Image.find(params[:image_id])
    image.assign_attributes(update_crop_params)
    ImageUpdateService.new(image).call

    PreviewService.new(document).try_create_preview(
      user: current_user,
      type: "image_updated",
    )

    if params[:wizard].present?
      redirect_to edit_image_path(document, image, params.permit(:wizard))
      return
    end

    redirect_to images_path(document), notice: t("images.index.flashes.cropped", file: image.filename)
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
        "title" => I18n.t!("images.edit.flashes.requirements"),
        "items" => @issues.items,
      }

      render :edit
      return
    end

    ImageUpdateService.new(@image).call

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

      redirect_to images_path(@document), notice: t("images.index.flashes.details_edited", file: @image.filename)
    end
  end

  def destroy
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:image_id])

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

    ImageDeleteService.new(image).call

    if params[:wizard] == "lead_image"
      redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.deleted", file: image.filename)
    else
      redirect_to images_path(document), notice: t("images.index.flashes.deleted", file: image.filename)
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

  def update_crop_params
    image_aspect_ratio = Image::HEIGHT.to_f / Image::WIDTH
    crop_height = params[:crop_width].to_i * image_aspect_ratio
    params.permit(:crop_x, :crop_y, :crop_width).merge(crop_height: crop_height.to_i)
  end
end
