# frozen_string_literal: true

module Versioned
  class LeadImageController < ApplicationController
    def choose
      Versioned::Document.transaction do
        document = Versioned::Document.with_current_edition
                                      .lock
                                      .find_by_param(params[:document_id])
        current_edition = document.current_edition
        image_revision = current_edition.image_revisions.find_by!(image_id: params[:image_id])

        next_revision = current_edition.build_next_revision(
          { lead_image_revision: image_revision },
          current_user,
        )

        current_edition.update!(revision: next_revision)
        current_edition.update_last_edited_at(current_user)

        PreviewService.new(current_edition).try_create_preview

        # TODO: timeline entry

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
        image_revision = current_edition.lead_image_revision

        next_revision = current_edition.build_next_revision(
          { lead_image_revision: nil },
          current_user,
        )

        current_edition.update!(revision: next_revision)
        current_edition.update_last_edited_at(current_user)

        PreviewService.new(current_edition).try_create_preview

        # TODO: timeline entry

        redirect_to versioned_document_path(document),
                    notice: t("documents.show.flashes.lead_image.removed", file: image_revision.filename)
      end
    end
  end
end
