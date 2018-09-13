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

    if image_uploader.valid?
      image = image_uploader.upload(document)
      image.asset_manager_file_url = upload_image_to_asset_manager(image)
      image.save!
      redirect_to edit_document_lead_image_path(params[:document_id], image.id)
    else
      redirect_to document_lead_image_path, alert: {
        "alerts" => image_uploader.errors,
        "title" => t("document_lead_image.index.error_summary_title"),
      }
    end
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
    DocumentPublishingService.new.publish_draft(document)
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
    AssetManagerService.new.upload(image.cropped_file)
  end
end
