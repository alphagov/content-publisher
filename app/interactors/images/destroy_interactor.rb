# frozen_string_literal: true

class Images::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :removed_lead_image,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_remove_image
      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def find_and_remove_image
    context.image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.remove_image(image_revision)
    edition.assign_revision(updater.next_revision, user).save!
    context.removed_lead_image = updater.removed_lead_image?
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :image_deleted, edition: edition)
  end

  def update_preview
    FailsafePreviewService.call(edition)
  end
end
