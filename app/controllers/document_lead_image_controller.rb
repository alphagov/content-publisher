# frozen_string_literal: true

class DocumentLeadImageController < ApplicationController
  def index
    @document = Document.find_by_param(params[:document_id])
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
    rescue GdsApi::BaseError => e
      Rails.logger.error(e)
      redirect_to document_images_path(document), alert_with_description: t("document_images.index.flashes.api_error")
      return
    end

    redirect_to document_path(document)
  end

  def choose
    document = Document.find_by_param(params[:document_id])

    begin
      DocumentUpdateService.update!(
        document: document,
        user: current_user,
        type: "lead_image_updated",
        attributes_to_update: { lead_image_id: params[:image_id] },
      )
    rescue GdsApi::BaseError => e
      Rails.logger.error(e)
      redirect_to document_images_path(document), alert_with_description: t("document_images.index.flashes.api_error")
      return
    end

    redirect_to document_path(document)
  end

  def remove
    document = Document.find_by_param(params[:document_id])

    begin
      DocumentUpdateService.update!(
        document: document,
        user: current_user,
        type: "lead_image_removed",
        attributes_to_update: { lead_image_id: nil },
      )
    rescue GdsApi::BaseError => e
      Rails.logger.error(e)
      redirect_to document_images_path(document), alert_with_description: t("document_images.index.flashes.api_error")
      return
    end

    redirect_to document_path(document)
  end

  def destroy
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:image_id])
    raise "Trying to delete image for a live document" if document.has_live_version_on_govuk

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
    rescue GdsApi::BaseError => e
      Rails.logger.error(e)
      redirect_to document_images_path(document), alert_with_description: t("document_images.index.flashes.api_error")
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
