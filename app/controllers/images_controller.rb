# frozen_string_literal: true

class ImagesController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    redirect_to images_path, alert_with_description: t("images.index.flashes.api_error")
  end

  def index
    @document = Document.with_current_edition.find_by_param(params[:document_id])
  end

  def create
    Document.transaction do
      @document = Document.with_current_edition.lock.find_by_param(params[:document_id])

      @issues = ::Requirements::ImageUploadChecker.new(params[:image]).issues

      if @issues.any?
        flash.now["alert_with_items"] = {
          "title" => I18n.t!("images.index.flashes.upload_requirements"),
          "items" => @issues.items,
        }

        render :index
        return
      end

      current_edition = @document.current_edition
      current_revision = current_edition.revision
      image_revision = ImageUploadService.new(params[:image], current_revision).call(current_user)

      updater = Versioning::RevisionUpdater.new(current_revision, current_user)
      update_image(updater, image_revision)
      next_revision = updater.next_revision

      current_edition.assign_revision(next_revision, current_user).save!

      PreviewService.new(current_edition).try_create_preview

      redirect_to crop_image_path(params[:document_id],
                                  image_revision.image_id,
                                  wizard: params[:wizard])
    end
  end

  def crop
    @document, @image_revision = find_document_and_image_revision(
      params[:document_id],
      params[:image_id],
    )
  end

  def update_crop
    Document.transaction do # rubocop:disable Metrics/BlockLength
      document, image_revision = find_locked_document_and_image_revision(
        params[:document_id],
        params[:image_id],
      )

      image_updater = Versioning::ImageRevisionUpdater.new(image_revision, current_user)
      next_image_revision = image_updater.assign_attributes(update_crop_params)

      current_edition = document.current_edition
      updater = Versioning::RevisionUpdater.new(current_edition.revision, current_user)
      update_image(updater, next_image_revision)
      next_revision = updater.next_revision

      if updater.changed?
        current_edition.assign_revision(next_revision, current_user).save!

        TimelineEntry.create_for_revision(
          entry_type: :image_updated,
          edition: current_edition,
        )

        PreviewService.new(document.current_edition).try_create_preview
      end

      if params[:wizard].present?
        redirect_to edit_image_path(document,
                                    image_revision.image_id,
                                    wizard: params[:wizard])
        return
      end

      redirect_to images_path(document),
                  notice: t("images.index.flashes.cropped", file: image_revision.filename)
    end
  end

  def edit
    @document, @image_revision = find_document_and_image_revision(
      params[:document_id],
      params[:image_id],
    )
  end

  def update
    Document.transaction do # rubocop:disable Metrics/BlockLength
      @document, image_revision = find_locked_document_and_image_revision(
        params[:document_id],
        params[:image_id],
      )

      image_updater = Versioning::ImageRevisionUpdater.new(image_revision, current_user)
      next_image_revision = image_updater.assign_attributes(update_params)

      @issues = Requirements::ImageRevisionChecker.new(next_image_revision)
                                                  .pre_preview_metadata_issues

      if @issues.any?
        @image_revision = next_image_revision

        flash.now["alert_with_items"] = {
          "title" => I18n.t!("images.edit.flashes.requirements"),
          "items" => @issues.items,
        }

        render :edit
        return
      end

      current_edition = @document.current_edition
      updater = Versioning::RevisionUpdater.new(current_edition.revision, current_user)
      update_image(updater, next_image_revision)
      update_lead_image(updater, next_image_revision, params[:lead_image] == "on")
      next_revision = updater.next_revision

      if updater.changed?
        timeline_entry_type = if lead_image_selected?(updater) then :lead_image_selected
                              elsif lead_image_removed?(updater) then :lead_image_removed
                              elsif image_updater.changed? then :image_updated
                              end

        TimelineEntry.create_for_revision(entry_type: timeline_entry_type,
                                          edition: current_edition)

        current_edition.assign_revision(next_revision, current_user).save!
        PreviewService.new(current_edition).try_create_preview
      end

      if lead_image_selected?(updater)
        redirect_to document_path(@document),
                    notice: t("documents.show.flashes.lead_image.selected",
                              file: next_image_revision.filename)
      elsif lead_image_removed?(updater)
        redirect_to images_path(@document),
                    notice: t("images.index.flashes.lead_image.removed",
                              file: next_image_revision.filename)
      elsif image_updater.changed?
        redirect_to images_path(@document),
                    notice: t("images.index.flashes.details_edited",
                              file: next_image_revision.filename)
      else
        redirect_to images_path(@document)
      end
    end
  end

  def destroy
    Document.transaction do
      document, image_revision = find_locked_document_and_image_revision(
        params[:document_id],
        params[:image_id],
      )

      current_edition = document.current_edition
      current_revision = current_edition.revision

      updater = Versioning::RevisionUpdater.new(current_revision, current_user)
      remove_image(updater, image_revision)
      next_revision = updater.next_revision
      current_edition.assign_revision(next_revision, current_user).save!

      TimelineEntry.create_for_revision(
        entry_type: :image_deleted,
        edition: current_edition,
      )

      PreviewService.new(current_edition).try_create_preview

      if params[:wizard] == "lead_image"
        redirect_to images_path(document), notice: t("images.index.flashes.lead_image.deleted", file: image_revision.filename)
      else
        redirect_to images_path(document), notice: t("images.index.flashes.deleted", file: image_revision.filename)
      end
    end
  end

  def download
    _, image_revision = find_document_and_image_revision(params[:document_id],
                                                         params[:image_id])

    variant = image_revision.crop_variant("960x640!").processed

    send_data(
      image_revision.blob.service.download(variant.key),
      filename: image_revision.filename,
      type: image_revision.content_type,
    )
  end

private

  def find_document_and_image_revision(document_id, image_id)
    document = Document.with_current_edition.find_by_param(document_id)

    image_revision = document.current_edition
                             .image_revisions
                             .find_by!(image_id: image_id)

    [document, image_revision]
  end

  def find_locked_document_and_image_revision(document_id, image_id)
    document = Document.with_current_edition.lock.find_by_param(document_id)

    image_revision = document.current_edition
                             .image_revisions
                             .find_by!(image_id: image_id)

    [document, image_revision]
  end

  def update_params
    params.require(:image_revision).permit(:caption, :alt_text, :credit)
  end

  def update_crop_params
    image_aspect_ratio = Image::HEIGHT.to_f / Image::WIDTH
    crop_height = params[:crop_width].to_i * image_aspect_ratio
    # FIXME: this will raise a warning because of unpermitted paramaters
    params.permit(:crop_x, :crop_y, :crop_width).merge(crop_height: crop_height.to_i)
  end

  def update_image(updater, image_revision)
    revisions = updater.revision.image_revisions
      .reject { |ir| ir.image_id == image_revision.image_id }

    updater.assign_attributes(image_revisions: revisions + [image_revision])

    if updater.revision.lead_image_revision&.image_id == image_revision.image_id
      updater.assign_attributes(lead_image_revision: image_revision)
    end
  end

  def update_lead_image(updater, image_revision, selected)
    if updater.revision.lead_image_revision&.image_id == image_revision.image_id
      updater.assign_attributes(lead_image_revision: nil) unless selected
    end

    if updater.revision.lead_image_revision&.image_id != image_revision.image_id
      updater.assign_attributes(lead_image_revision: image_revision) if selected
    end
  end

  def remove_image(updater, image_revision)
    image_revisions = updater.revision.image_revisions - [image_revision]
    updater.assign_attributes(image_revisions: image_revisions)

    if updater.revision.lead_image_revision == image_revision
      updater.assign_attributes(lead_image_revision: nil)
    end
  end

  def lead_image_selected?(updater)
    updater.changed_attributes[:lead_image_revision].present?
  end

  def lead_image_removed?(updater)
    !lead_image_selected?(updater) && updater.changed_attributes.key?(:lead_image_revision)
  end
end
