# frozen_string_literal: true

class ImagesController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
    render layout: rendering_context
  end

  def create
    result = Images::CreateInteractor.call(params: params, user: current_user)
    edition, image_revision, issues = result.to_h.values_at(:edition,
                                                            :image_revision,
                                                            :issues)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :index,
             assigns: { edition: edition },
             layout: rendering_context,
             status: :unprocessable_entity
    else
      redirect_to crop_image_path(params[:document],
                                  image_revision.image_id,
                                  wizard: "upload")
    end
  end

  def crop
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    render layout: rendering_context
  end

  def update_crop
    result = Images::UpdateCropInteractor.call(params: params, user: current_user)
    image_revision = result.image_revision
    redirect_to edit_image_path(params[:document],
                                image_revision.image_id,
                                wizard: params[:wizard])
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:editable?)
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    render layout: rendering_context
  end

  def update
    result = Images::UpdateInteractor.call(params: params, user: current_user)

    edition = result.edition
    image_revision = result.image_revision
    issues = result.issues
    lead_selected = result.selected_lead_image
    lead_removed = result.removed_lead_image

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :edit,
             assigns: { edition: edition,
                        image_revision: image_revision,
                        issues: issues },
             layout: rendering_context,
             status: :unprocessable_entity
    elsif lead_selected
      redirect_to document_path(params[:document]),
                  notice: t("documents.show.flashes.lead_image.selected", file: image_revision.filename)
    elsif lead_removed
      redirect_to images_path(params[:document]),
                  notice: t("images.index.flashes.lead_image.removed", file: image_revision.filename)
    else
      redirect_to images_path(params[:document])
    end
  end

  def destroy
    result = Images::DestroyInteractor.call(params: params, user: current_user)
    image_revision, removed_lead = result.to_h.values_at(:image_revision, :removed_lead_image)

    if removed_lead
      redirect_to images_path(params[:document]),
                  notice: t("images.index.flashes.lead_image.deleted",
                            file: image_revision.filename)
    else
      redirect_to images_path(params[:document]),
                  notice: t("images.index.flashes.deleted",
                            file: image_revision.filename)
    end
  end

  def download
    edition = Edition.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
    image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    variant = image_revision.crop_variant("960x640!").processed

    send_data(
      image_revision.blob.service.download(variant.key),
      filename: image_revision.filename,
      type: image_revision.content_type,
    )
  end
end
