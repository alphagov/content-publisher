# frozen_string_literal: true

class LeadImageController < ApplicationController
  def choose
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
      updater.assign(lead_image_revision: image_revision)

      if updater.changed?
        edition.assign_revision(updater.next_revision, current_user).save!
        TimelineEntry.create_for_revision(entry_type: :lead_image_selected, edition: edition)
        PreviewService.new(edition).try_create_preview
      end

      redirect_to document_path(edition.document),
                  notice: t("documents.show.flashes.lead_image.selected", file: image_revision.filename)
    end
  end

  def remove
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      image_revision = edition.lead_image_revision
      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
      updater.assign(lead_image_revision: nil)

      if updater.changed?
        edition.assign_revision(updater.next_revision, current_user).save!
        TimelineEntry.create_for_revision(entry_type: :lead_image_removed, edition: edition)
        PreviewService.new(edition).try_create_preview
      end

      redirect_to images_path(edition.document),
                  notice: t("images.index.flashes.lead_image.removed", file: image_revision.filename)
    end
  end
end
