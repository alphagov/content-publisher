# frozen_string_literal: true

class LeadImageController < ApplicationController
  def choose
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:document_id])

      current_edition = document.current_edition
      current_revision = current_edition.revision

      image_revision = current_revision.image_revisions.find_by!(image_id: params[:image_id])

      if current_revision.lead_image_revision != image_revision
        next_revision = current_revision.build_revision_update(
          { lead_image_revision: image_revision },
          current_user,
        )

        current_edition.assign_revision(next_revision, current_user).save!

        TimelineEntry.create_for_revision(entry_type: :lead_image_updated,
                                          edition: current_edition)

        PreviewService.new(current_edition).try_create_preview
      end

      redirect_to document_path(document),
                  notice: t("documents.show.flashes.lead_image.chosen", file: image_revision.filename)
    end
  end

  def remove
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:document_id])

      current_edition = document.current_edition
      current_revision = current_edition.revision

      if current_revision.lead_image_revision
        image_revision = current_revision.lead_image_revision

        next_revision = current_revision.build_revision_update(
          { lead_image_revision: nil },
          current_user,
        )

        current_edition.assign_revision(next_revision, current_user).save!

        TimelineEntry.create_for_revision(entry_type: :lead_image_removed,
                                          edition: current_edition)

        PreviewService.new(current_edition).try_create_preview
      end

      redirect_to document_path(document),
                  notice: t("documents.show.flashes.lead_image.removed", file: image_revision.filename)
    end
  end
end
