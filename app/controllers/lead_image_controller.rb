# frozen_string_literal: true

class LeadImageController < ApplicationController
  def choose
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:document_id])
      current_edition = document.current_edition
      image_revision = current_edition.image_revisions.find_by!(image_id: params[:image_id])

      updater = Versioning::RevisionUpdater.new(current_edition.revision, current_user)
      next_revision = updater.assign_attributes(lead_image_revision: image_revision)

      if updater.changed?
        current_edition.assign_revision(next_revision, current_user).save!
        TimelineEntry.create_for_revision(entry_type: :lead_image_selected, edition: current_edition)
        PreviewService.new(current_edition).try_create_preview
      end

      redirect_to document_path(document),
                  notice: t("documents.show.flashes.lead_image.selected", file: image_revision.filename)
    end
  end

  def remove
    Document.transaction do
      document = Document.with_current_edition.lock.find_by_param(params[:document_id])
      current_edition = document.current_edition
      image_revision = current_edition.lead_image_revision

      updater = Versioning::RevisionUpdater.new(current_edition.revision, current_user)
      next_revision = updater.assign_attributes(lead_image_revision: nil)

      if updater.changed?
        current_edition.assign_revision(next_revision, current_user).save!
        TimelineEntry.create_for_revision(entry_type: :lead_image_removed, edition: current_edition)
        PreviewService.new(current_edition).try_create_preview
      end

      redirect_to images_path(document),
                  notice: t("images.index.flashes.lead_image.removed", file: image_revision.filename)
    end
  end
end
