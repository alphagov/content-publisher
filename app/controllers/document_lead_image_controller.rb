# frozen_string_literal: true

class DocumentLeadImageController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    redirect_to document_images_path, alert_with_description: t("document_images.index.flashes.api_error")
  end

  def index
    @document = Document.find_by_param(params[:document_id])
  end

  def update
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:image_id])
    image.update!(update_params)

    document.assign_attributes(lead_image_id: image.id)

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "lead_image_updated",
    )

    redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.added", file: image.filename)
  end

  def choose
    document = Document.find_by_param(params[:document_id])
    image = Image.find(params[:image_id])

    document.assign_attributes(lead_image_id: params[:image_id])

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "lead_image_updated",
    )

    redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.chosen", file: image.filename)
  end

  def remove
    document = Document.find_by_param(params[:document_id])
    image = document.lead_image
    document.assign_attributes(lead_image_id: nil)

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "lead_image_removed",
    )

    redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.removed", file: image.filename)
  end

  def destroy
    document = Document.find_by_param(params[:document_id])
    image = document.images.find(params[:image_id])
    raise "Trying to delete image for a live document" if document.has_live_version_on_govuk

    document.assign_attributes(lead_image_id: nil)

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "lead_image_removed",
    )

    AssetManagerService.new.delete(image)
    image.destroy!
    redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.deleted", file: image.filename)
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
