# frozen_string_literal: true

class Images::DestroyInteractor
  include Interactor

  delegate :params, :user, to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_image
      update_edition
      create_timeline_entry
      update_preview
      update_context
    end
  end

private

  def find_and_lock_edition
    @edition = Edition.lock.find_current(document: params[:document])
  end

  def find_image
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
  end

  def update_edition
    @updater = Versioning::RevisionUpdater.new(@edition.revision, user)
    @updater.remove_image(@image_revision)
    @edition.assign_revision(@updater.next_revision, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :image_deleted, edition: @edition)
  end

  def update_preview
    PreviewService.new(@edition).try_create_preview
  end

  def update_context
    context.edition = @edition
    context.image_revision = @image_revision
    context.removed_lead_image = @updater.removed_lead_image?
  end
end
