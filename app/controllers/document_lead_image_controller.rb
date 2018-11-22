# frozen_string_literal: true

class DocumentLeadImageController < ApplicationController
  def choose
    document = Document.find_by_param(params[:document_id])
    image = Image.find(params[:image_id])

    document.assign_attributes(lead_image_id: params[:image_id])

    PreviewService.new(document).try_create_preview(
      user: current_user,
      type: "lead_image_updated",
    )

    redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.chosen", file: image.filename)
  end

  def remove
    document = Document.find_by_param(params[:document_id])
    image = document.lead_image
    document.assign_attributes(lead_image_id: nil)

    PreviewService.new(document).try_create_preview(
      user: current_user,
      type: "lead_image_removed",
    )

    redirect_to document_path(document), notice: t("documents.show.flashes.lead_image.removed", file: image.filename)
  end
end
