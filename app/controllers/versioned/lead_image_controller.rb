# frozen_string_literal: true

module Versioned
  class LeadImageController < BaseController
    def choose
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:document_id])
        current_edition = document.current_edition
        image_revision = current_edition.image_revisions.find_by!(image_id: params[:image_id])

        if current_edition.lead_image_revision != image_revision
          next_revision = current_edition.build_revision_update(
            { lead_image_revision: image_revision },
            current_user,
          )

          current_edition.assign_revision(next_revision, current_user).save!

          Versioned::TimelineEntry.create_for_revision(
            entry_type: :lead_image_updated,
            edition: current_edition,
          )

          PreviewService.new(current_edition).try_create_preview
        end

        redirect_to versioned_document_path(document),
                    notice: t("documents.show.flashes.lead_image.chosen", file: image_revision.filename)
      end
    end

    def remove
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:document_id])

        current_edition = document.current_edition

        if current_edition.lead_image_revision
          image_revision = current_edition.lead_image_revision

          next_revision = current_edition.build_revision_update(
            { lead_image_revision: nil },
            current_user,
          )

          current_edition.assign_revision(next_revision, current_user).save!

          Versioned::TimelineEntry.create_for_revision(
            entry_type: :lead_image_removed,
            edition: current_edition,
          )

          PreviewService.new(current_edition).try_create_preview
        end

        redirect_to versioned_document_path(document),
                    notice: t("documents.show.flashes.lead_image.removed", file: image_revision.filename)
      end
    end
  end
end
