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
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      @issues = ::Requirements::ImageUploadChecker.new(params[:image]).issues

      if @issues.any?
        flash.now["alert_with_items"] = {
          "title" => I18n.t!("images.index.flashes.upload_requirements"),
          "items" => @issues.items,
        }

        render :index,
               assigns: { edition: edition },
               layout: rendering_context,
               status: :unprocessable_entity
        next
      end

      image_revision = ImageUploadService.new(params[:image], edition.revision).call(current_user)

      next_revision = edition.revision.build_revision_update_for_image_upsert(
        image_revision,
        current_user,
      )

      edition.assign_revision(next_revision, current_user).save!
      PreviewService.new(edition).try_create_preview
      redirect_to crop_image_path(params[:document], image_revision.image_id, wizard: "upload")
    end
  end

  def crop
    @edition = Edition.find_current(document: params[:document])
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
    render layout: rendering_context
  end

  def update_crop
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      previous_image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])

      image_revision = previous_image_revision.build_revision_update(
        update_crop_params,
        current_user,
      )

      if image_revision != previous_image_revision
        next_revision = edition.revision.build_revision_update_for_image_upsert(
          image_revision,
          current_user,
        )

        edition.assign_revision(next_revision, current_user).save!

        TimelineEntry.create_for_revision(
          entry_type: :image_updated,
          edition: edition,
        )

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
    Edition.find_and_lock_current(document: params[:document]) do |edition| # rubocop:disable Metrics/BlockLength
      previous_image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])

      image_revision = previous_image_revision.build_revision_update(
        update_params,
        current_user,
      )

      issues = Requirements::ImageRevisionChecker.new(image_revision)
                                                 .pre_preview_metadata_issues

      if issues.any?
        flash.now["alert_with_items"] = {
          "title" => I18n.t!("images.edit.flashes.requirements"),
          "items" => issues.items,
        }

        render :edit,
               assigns: { edition: edition, image_revision: image_revision, issues: issues },
               layout: rendering_context,
               status: :unprocessable_entity
        next
      end

      lead_image_revision = next_lead_image_revision(
        edition.revision,
        image_revision,
        params[:lead_image] == "on",
      )

      current_revision = edition.revision

      next_revision = current_revision.build_revision_update_for_lead_image_upsert(
        image_revision,
        lead_image_revision,
        current_user,
      )

      if current_revision != next_revision
        timeline_entry_type = if lead_image_selected?(current_revision, next_revision)
                                :lead_image_selected
                              elsif lead_image_removed?(current_revision, next_revision)
                                :lead_image_removed
                              else
                                :image_updated
                              end

        TimelineEntry.create_for_revision(entry_type: timeline_entry_type,
                                          edition: edition)

        edition.assign_revision(next_revision, current_user).save!
        PreviewService.new(edition).try_create_preview
      end

      if lead_image_selected?(current_revision, next_revision)
        redirect_to document_path(edition.document),
                    notice: t("documents.show.flashes.lead_image.selected",
                              file: image_revision.filename)
      elsif lead_image_removed?(current_revision, next_revision)
        redirect_to images_path(edition.document),
                    notice: t("images.index.flashes.lead_image.removed",
                              file: image_revision.filename)
      else
        redirect_to images_path(edition.document)
      end
    end
  end

  def destroy
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
      current_revision = edition.revision

      next_revision = current_revision.build_revision_update_for_image_removed(
        image_revision,
        current_user,
      )

      edition.assign_revision(next_revision, current_user).save!

      TimelineEntry.create_for_revision(
        entry_type: :image_deleted,
        edition: edition,
      )

      PreviewService.new(edition).try_create_preview

      if lead_image_removed?(current_revision, next_revision)
        redirect_to images_path(edition.document),
                    notice: t("images.index.flashes.lead_image.deleted", file: image_revision.filename)
      else
        redirect_to images_path(edition.document),
                    notice: t("images.index.flashes.deleted", file: image_revision.filename)
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

  def next_lead_image_revision(revision, image_revision, selected)
    return image_revision if selected

    currently_lead = revision.lead_image_revision&.image_id == image_revision.image_id
    return if currently_lead && !selected

    revision.lead_image_revision
  end

  def lead_image_selected?(current_revision, next_revision)
    next_revision.lead_image_revision.present? &&
      current_revision.lead_image_revision != next_revision.lead_image_revision
  end

  def lead_image_removed?(current_revision, next_revision)
    current_revision.lead_image_revision.present? &&
      next_revision.lead_image_revision.nil?
  end
end
