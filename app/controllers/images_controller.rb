# frozen_string_literal: true

class ImagesController < ApplicationController
  def index
    @edition = Edition.find_current(document: params[:document])
    render layout: rendering_context
  end

  def create
    result = Images::CreateActor.call(document: params[:document],
                                      image: params[:image],
                                      user: current_user)

    if result.aborted?(:issues)
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("images.index.flashes.upload_requirements"),
        "items" => result.issues.items,
      }

      render :index,
             assigns: { issues: result.issues, edition: result.edition },
             layout: rendering_context,
             status: :unprocessable_entity

      return
    end

    redirect_to crop_image_path(params[:document],
                                result.image_revision.image_id,
                                wizard: "upload")
  end

  def crop
    @edition = Edition.find_current(document: params[:document])
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    render layout: rendering_context
  end

  def update_crop
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
      image_updater = Versioning::ImageRevisionUpdater.new(image_revision, current_user)
      image_updater.assign(update_crop_params)

      if image_updater.changed?
        updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
        updater.update_image(image_updater.next_revision)
        edition.assign_revision(updater.next_revision, current_user).save!
        TimelineEntry.create_for_revision(entry_type: :image_updated, edition: edition)
        PreviewService.new(edition).try_create_preview
      end

      redirect_to edit_image_path(edition.document, image_revision.image_id, wizard: params[:wizard])
    end
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    render layout: rendering_context
  end

  def update
    result = Images::UpdateActor.call(document: params[:document],
                                      image_id: params[:image_id],
                                      lead_image: params[:lead_image],
                                      user: current_user,
                                      update_params: update_params)

    if result.aborted?(:issues)
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("images.edit.flashes.requirements"),
        "items" => result.issues.items,
      }

      render :edit,
             assigns: { edition: result.edition, image_revision: result.next_image_revision, issues: result.issues },
             layout: rendering_context,
             status: :unprocessable_entity
      return
    end

    if result.success?(:lead_image_selected)
      redirect_to document_path(params[:document]),
                  notice: t("documents.show.flashes.lead_image.selected",
                            file: result.image_revision.filename)
    elsif result.success?(:lead_image_removed)
      redirect_to images_path(params[:document]),
                  notice: t("images.index.flashes.lead_image.removed",
                            file: result.image_revision.filename)
    else
      redirect_to images_path(params[:document])
    end
  end

  def destroy
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)

      updater.remove_image(image_revision)
      edition.assign_revision(updater.next_revision, current_user).save!

      TimelineEntry.create_for_revision(entry_type: :image_deleted, edition: edition)
      PreviewService.new(edition).try_create_preview

      if updater.removed_lead_image?
        redirect_to images_path(edition.document),
                    notice: t("images.index.flashes.lead_image.deleted",
                              file: image_revision.filename)
      else
        redirect_to images_path(edition.document),
                    notice: t("images.index.flashes.deleted",
                              file: image_revision.filename)
      end
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

private

  def update_params
    params.require(:image_revision).permit(:caption, :alt_text, :credit)
  end

  def update_crop_params
    image_aspect_ratio = Image::HEIGHT.to_f / Image::WIDTH
    crop_height = params[:crop_width].to_i * image_aspect_ratio
    # FIXME: this will raise a warning because of unpermitted paramaters
    params.permit(:crop_x, :crop_y, :crop_width).merge(crop_height: crop_height.to_i)
  end
end
