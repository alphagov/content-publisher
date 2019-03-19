# frozen_string_literal: true

class ImagesController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    redirect_to images_path, alert_with_description: t("images.index.flashes.api_error")
  end

  def index
    @edition = Edition.find_current(document: params[:document])
    render layout: rendering_context
  end

  def create
    result = Images::Create.call(params: params, user: current_user)
    if result.failure?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("images.index.flashes.upload_requirements"),
        "items" => result.issues.items,
      }

      render :index,
             assigns: { edition: result.edition },
             layout: rendering_context,
             status: :unprocessable_entity
    else
      redirect_to crop_image_path(result.edition.document,
                                  result.image_revision.image_id,
                                  wizard: "upload")
    end
  end

  def crop
    @edition = Edition.find_current(document: params[:document])
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    render layout: rendering_context
  end

  def update_crop
    result = Images::UpdateCrop.call(params: params, user: current_user)
    redirect_to edit_image_path(result.edition.document,
                                result.image_revision.image_id,
                                wizard: params[:wizard])
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    render layout: rendering_context
  end

  def update
    result = Images::Update.call(params: params, user: current_user)

    if result.failure?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("images.edit.flashes.requirements"),
        "items" => result.issues.items,
      }

      render :edit,
             assigns: { edition: result.edition,
                        image_revision: result.image_revision,
                        issues: result.issues },
             layout: rendering_context,
             status: :unprocessable_entity
    else
      document = result.edition.document

      if result.updater.selected_lead_image?
        redirect_to document_path(document),
                    notice: t("documents.show.flashes.lead_image.selected",
                              file: result.image_revision.filename)
      elsif result.updater.removed_lead_image?
        redirect_to images_path(document),
                    notice: t("images.index.flashes.lead_image.removed",
                              file: result.image_revision.filename)
      else
        redirect_to images_path(document)
      end
    end
  end

  def destroy
    result = Images::Destroy.call(params: params, user: current_user)
    document = result.edition.document

    if result.updater.removed_lead_image?
      redirect_to images_path(document),
                  notice: t("images.index.flashes.lead_image.deleted",
                            file: result.image_revision.filename)
    else
      redirect_to images_path(document),
                  notice: t("images.index.flashes.deleted",
                            file: result.image_revision.filename)
    end
  end

  def download
    edition = Edition.find_current(document: params[:document])
    image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    variant = image_revision.crop_variant("960x640!").processed

    send_data(
      image_revision.blob.service.download(variant.key),
      filename: image_revision.filename,
      type: image_revision.content_type,
    )
  end
end
