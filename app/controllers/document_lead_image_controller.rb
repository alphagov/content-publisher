# frozen_string_literal: true

class DocumentLeadImageController < ApplicationController
  def index
    @document = Document.find_by_param(params[:document_id])
  end

  def create
    document = Document.find_by_param(params[:document_id])

    unless params[:image]
      redirect_to document_lead_image_path, alert: t("document_lead_image.index.no_file_selected")
      return
    end

    image_uploader = ImageUploader.new(params.require(:image))

    unless image_uploader.valid?
      redirect_to document_lead_image_path, alert: {
        "alerts" => image_uploader.errors,
        "title" => t("document_lead_image.index.error_summary_title"),
      }
      return
    end

    begin
      image = image_uploader.upload(document)
      image.asset_manager_file_url = upload_image_to_asset_manager(image)
    rescue GdsApi::BaseError
      redirect_to document_lead_image_path, alert_with_description: t("document_lead_image.index.flashes.api_error")
      return
    end

    image.save!
    redirect_to crop_document_lead_image_path(params[:document_id], image.id)
  end

  def crop
    @document = Document.find_by_param(params[:document_id])
    @image = @document.images.find(params[:image_id])
  end

  def update_crop
    document = Document.find_by_param(params[:document_id])
    image = Image.find(params[:image_id])


    begin
      Image.transaction do
        image.update!(update_crop_params)
        asset_manager_file_url = upload_image_to_asset_manager(image)
        delete_image_from_asset_manager(image)
        image.asset_manager_file_url = asset_manager_file_url
        image.save!
      end

      DocumentUpdateService.update!(
        document: document,
        user: current_user,
        type: "image_updated",
        attributes_to_update: {},
      )
    rescue GdsApi::BaseError
      redirect_to document_lead_image_path(document), alert_with_description: t("document_lead_image.index.flashes.api_error")
      return
    end

    if params[:next_screen] == "lead-image"
      redirect_to document_lead_image_path(document)
      return
    end

    redirect_to edit_document_lead_image_path(document, image)
  end

  def edit
    @document = Document.find_by_param(params[:document_id])
    @image = Image.find_by(id: params[:image_id])
  end

  def update
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:image_id])
    image.update!(update_params)

    begin
      DocumentUpdateService.update!(
        document: document,
        user: current_user,
        type: "lead_image_updated",
        attributes_to_update: { lead_image_id: image.id },
      )
    rescue GdsApi::BaseError
      redirect_to document_lead_image_path(document), alert_with_description: t("document_lead_image.index.flashes.api_error")
      return
    end

    if params[:next_screen] == "lead-image"
      redirect_to document_lead_image_path(document)
      return
    end

    redirect_to document_path(document)
  end

  def choose_image
    document = Document.find_by_param(params[:document_id])

    begin
      DocumentUpdateService.update!(
        document: document,
        user: current_user,
        type: "lead_image_updated",
        attributes_to_update: { lead_image_id: params[:image_id] },
      )
    rescue GdsApi::BaseError
      redirect_to document_lead_image_path(document), alert_with_description: t("document_lead_image.index.flashes.api_error")
      return
    end

    redirect_to document_path(document)
  end

  def delete_image
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:image_id])

    begin
      if image.id == document.lead_image_id
        DocumentUpdateService.update!(
          document: document,
          user: current_user,
          type: "lead_image_removed",
          attributes_to_update: { lead_image_id: nil },
        )
      end

      AssetManagerService.new.delete(image)
      image.destroy
    rescue GdsApi::BaseError
      redirect_to document_lead_image_path(document), alert_with_description: t("document_lead_image.index.flashes.api_error")
      return
    end

    redirect_to document_lead_image_path(document), notice: t("document_lead_image.index.flashes.image_deleted")
  end

  def destroy
    document = Document.find_by_param(params[:document_id])

    begin
      DocumentUpdateService.update!(
        document: document,
        user: current_user,
        type: "lead_image_removed",
        attributes_to_update: { lead_image_id: nil },
      )
    rescue GdsApi::BaseError
      redirect_to document_lead_image_path(document), alert_with_description: t("document_lead_image.index.flashes.api_error")
      return
    end

    redirect_to document_path(document)
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
    params.permit(:crop_x, :crop_y, :crop_width, :crop_height)
  end
end
