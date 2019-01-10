# frozen_string_literal: true

module Versioned
  class ImagesController < BaseController
    rescue_from GdsApi::BaseError do |e|
      GovukError.notify(e)
      redirect_to images_path, alert_with_description: t("images.index.flashes.api_error")
    end

    def index
      @document = Versioned::Document.with_current_edition
                                     .find_by_param(params[:document_id])
    end

    def create
      Versioned::Document.transaction do
        @document = Versioned::Document.with_current_edition
                                       .lock
                                       .find_by_param(params[:document_id])

        @issues = ::Requirements::ImageUploadChecker.new(params[:image]).issues

        if @issues.any?
          flash.now["alert_with_items"] = {
            "title" => I18n.t!("images.index.flashes.upload_requirements"),
            "items" => @issues.items,
          }

          render :index
          return
        end

        image_revision = Versioned::ImageUploadService.new(params[:image]).call(current_user)

        current_edition = @document.current_edition
        next_revision = current_edition.build_revision_update_for_image_upsert(
          image_revision,
          current_user,
        )

        current_edition.update!(revision: next_revision)
        current_edition.update_last_edited_at(current_user)

        Versioned::PreviewService.new(current_edition).try_create_preview

        redirect_to versioned_crop_image_path(params[:document_id],
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
      Versioned::Document.transaction do # rubocop:disable Metrics/BlockLength
        document, previous_image_revision = find_locked_document_and_image_revision(
          params[:document_id],
          params[:image_id],
        )

        image_revision = previous_image_revision.build_revision_update(
          update_crop_params,
          current_user,
          keep_variants: false,
        )

        if image_revision != previous_image_revision
          current_edition = document.current_edition

          next_revision = current_edition.build_revision_update_for_image_upsert(
            image_revision,
            current_user,
          )

          current_edition.update!(revision: next_revision)
          current_edition.update_last_edited_at(current_user)

          lead = next_revision.lead_image_revision == image_revision

          Versioned::TimelineEntry.create_for_revision(
            entry_type: lead ? :lead_image_updated : :image_updated,
            edition: current_edition,
          )

          # TODO remove old images from asset manager

          Versioned::PreviewService.new(current_edition).try_create_preview
        end


        if params[:wizard].present?
          redirect_to versioned_edit_image_path(document,
                                                image_revision.image_id,
                                                wizard: params[:wizard])
          return
        end

        redirect_to versioned_images_path(document),
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
      Versioned::Document.transaction do # rubocop:disable Metrics/BlockLength
        @document, previous_image_revision = find_locked_document_and_image_revision(
          params[:document_id],
          params[:image_id],
        )

        @image_revision = previous_image_revision.build_revision_update(
          update_params,
          current_user,
          keep_variants: true,
        )

        @issues = Versioned::Requirements::ImageRevisionChecker.new(@image_revision)
                                                               .pre_preview_metadata_issues

        if @issues.any?
          flash.now["alert_with_items"] = {
            "title" => I18n.t!("images.edit.flashes.requirements"),
            "items" => @issues.items,
          }

          render :edit
          return
        end

        if @image_revision != previous_image_revision
          current_edition = @document.current_edition

          next_revision = current_edition.build_revision_update_for_image_upsert(
            @image_revision,
            current_user,
          )
          next_revision.lead_image_revision = @image_revision if params[:wizard] == "lead_image"

          current_edition.update!(revision: next_revision)
          current_edition.update_last_edited_at(current_user)

          if params[:wizard] == "lead_image"
            Versioned::TimelineEntry.create_for_revision(
              entry_type: :lead_image_updated,
              edition: current_edition,
            )
          else
            Versioned::TimelineEntry.create_for_revision(
              entry_type: :image_updated,
              edition: current_edition,
            )
          end

          Versioned::PreviewService.new(current_edition).try_create_preview
        end

        if params[:wizard] == "lead_image"
          redirect_to versioned_document_path(@document),
                      notice: t("documents.show.flashes.lead_image.added",
                                file: @image_revision.filename)
        else
          redirect_to versioned_images_path(@document),
                      notice: t("images.index.flashes.details_edited",
                                file: @image_revision.filename)
        end
      end
    end

    def destroy
      Versioned::Document.transaction do
        document, image_revision = find_locked_document_and_image_revision(
          params[:document_id],
          params[:image_id],
        )

        current_edition = document.current_edition
        lead = image_revision == current_edition.lead_image_revision

        next_revision = current_edition.build_revision_update_for_image_removed(
          image_revision,
          current_user,
        )

        current_edition.update!(revision: next_revision)
        current_edition.update_last_edited_at(current_user)

        Versioned::TimelineEntry.create_for_revision(
          entry_type: lead ? :lead_image_removed : :image_removed,
          edition: current_edition,
        )

        # TODO remove images from asset manager

        Versioned::PreviewService.new(current_edition).try_create_preview

        if params[:wizard] == "lead_image"
          redirect_to versioned_document_path(document), notice: t("documents.show.flashes.lead_image.deleted", file: image_revision.filename)
        else
          redirect_to versioned_images_path(document), notice: t("images.index.flashes.deleted", file: image_revision.filename)
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
      document = Versioned::Document.with_current_edition
                                    .find_by_param(document_id)

      image_revision = document.current_edition
                               .image_revisions
                               .find_by!(image_id: image_id)

      [document, image_revision]
    end

    def find_locked_document_and_image_revision(document_id, image_id)
      document = Versioned::Document.with_current_edition
                                    .lock
                                    .find_by_param(document_id)

      image_revision = document.current_edition
                               .image_revisions
                               .find_by!(image_id: image_id)

      [document, image_revision]
    end

    def update_params
      params.require(:image_revision).permit(:caption, :alt_text, :credit)
    end

    def update_crop_params
      image_aspect_ratio = Versioned::ImageRevision::HEIGHT.to_f / Versioned::ImageRevision::WIDTH
      crop_height = params[:crop_width].to_i * image_aspect_ratio
      # FIXME: this will raise a warning because of unpermitted paramaters
      params.permit(:crop_x, :crop_y, :crop_width).merge(crop_height: crop_height.to_i)
    end
  end
end
