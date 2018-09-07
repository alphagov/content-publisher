# frozen_string_literal: true

class DocumentLeadImageController < ApplicationController
  def index
    @document = Document.find_by_param(params[:document_id])
  end

  def create
    document = Document.find_by_param(params[:document_id])
    upload = UploadedImageService.new(params.require(:image)).process

    if upload.valid?
      image = create_image_from_upload(upload, document)
      redirect_to edit_document_lead_image_path(params[:document_id], image.id)
    else
      redirect_to document_lead_image_path, alert: upload.errors
    end
  end

  def edit
    @document = Document.find_by_param(params[:document_id])
    @image = Image.find_by(id: params[:image_id])
  end

  def update
    document = Document.find_by_param(params[:document_id])
    image = Image.find_by(id: params[:image_id])
    image.update(update_params)
    document.update(lead_image_id: image.id)
    if params[:next] == "lead-image"
      redirect_to document_lead_image_path(document)
      return
    end
    redirect_to document_path(document)
  end

private

  def update_params
    params.permit(:caption, :alt_text, :credit)
  end

  def create_image_from_upload(upload, document)
    blob = ActiveStorage::Blob.create_after_upload!(
      io: upload.file,
      filename: upload.filename,
      content_type: upload.mime_type,
    )

    Image.create!(
      document: document,
      blob: blob,
      filename: blob.filename,
      width: upload.dimensions[:width],
      height: upload.dimensions[:height],
      crop_x: upload.crop_dimensions[:x],
      crop_y: upload.crop_dimensions[:y],
      crop_width: upload.crop_dimensions[:width],
      crop_height: upload.crop_dimensions[:height],
    )
  end
end
