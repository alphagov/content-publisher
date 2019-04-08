# frozen_string_literal: true

class Images::DestroyInteractor
  include Interactor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :removed_lead_image,
           to: :context

  def initialize(params:, user:)
    super
  end

  def call
    Edition.transaction do
      context.edition = Edition.lock.find_current(document: params[:document])
      context.image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])

      updater = remove_image(image_revision)
      create_timeline_entry
      update_preview

      context.removed_lead_image = updater.removed_lead_image?
    end
  end

private

  def remove_image(image_revision)
    Versioning::RevisionUpdater.new(edition.revision, user).tap do |updater|
      updater.remove_image(image_revision)
      edition.assign_revision(updater.next_revision, user).save!
    end
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :image_deleted, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
