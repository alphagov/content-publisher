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
      redirect_to document_lead_image_path, alert_with_description: {
        "title" => t("document_lead_image.index.flashes.asset_manager_error.title"),
        "description" => t("document_lead_image.index.flashes.asset_manager_error.description"),
      }
      return
    end
    image.save!
    redirect_to edit_document_lead_image_path(params[:document_id], image.id)
  end

  def edit
    @document = Document.find_by_param(params[:document_id])
    @image = Image.find_by(id: params[:image_id])
  end

  def update
    document = Document.find_by_param(params[:document_id])
    image = Image.find_by(id: params[:image_id])
    image.update!(update_params)
    document.update!(lead_image_id: image.id)
    begin
      DocumentPublishingService.new.publish_draft(document)
    rescue GdsApi::BaseError
      redirect_to document_lead_image_path(document), alert_with_description: t("document_lead_image.index.flashes.publishing_api_error")
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
    document.update!(lead_image_id: params[:image_id])
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document_path(document)
  end

  def destroy
    document = Document.find_by_param(params[:document_id])
    document.update!(lead_image_id: nil)
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document_path(document)
  end

private

  def update_params
    params.permit(:caption, :alt_text, :credit)
  end

  def upload_image_to_asset_manager(image)
    AssetManagerService.new.upload_bytes(image, image.cropped_bytes)
  end
end
