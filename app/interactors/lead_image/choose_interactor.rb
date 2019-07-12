# frozen_string_literal: true

class LeadImage::ChooseInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_image_revision

      choose_lead_image

      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def find_image_revision
    context.image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
  end

  def choose_lead_image
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(lead_image_revision: image_revision)

    context.fail! unless updater.changed?
    edition.assign_revision(updater.next_revision, user).save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :lead_image_selected, edition: edition)
  end

  def update_preview
    PreviewService.new(edition).try_create_preview
  end
end
