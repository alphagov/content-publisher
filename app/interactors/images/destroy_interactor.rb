# frozen_string_literal: true

class Images::DestroyInteractor
  include Interactor

  delegate :params, :user, to: :context

  def call
    Edition.transaction do
      edition = find_and_lock_edition
      image_revision = find_image(edition)

      updater = update_edition(edition, image_revision)

      create_timeline_entry(edition)
      update_preview(edition)

      update_context(edition: edition,
                     image_revision: image_revision,
                     updater: updater)
    end
  end

private

  def find_and_lock_edition
    Edition.lock.find_current(document: params[:document])
  end

  def find_image(edition)
    edition.image_revisions.find_by!(image_id: params[:image_id])
  end

  def update_edition(edition, image_revision)
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.remove_image(image_revision)
    edition.assign_revision(updater.next_revision, user).save!
    updater
  end

  def create_timeline_entry(edition)
    TimelineEntry.create_for_revision(entry_type: :image_deleted, edition: edition)
  end

  def update_preview(edition)
    PreviewService.new(edition).try_create_preview
  end

  def update_context(edition:, image_revision:, updater:)
    context.edition = edition
    context.image_revision = image_revision
    context.removed_lead_image = updater.removed_lead_image?
  end
end
