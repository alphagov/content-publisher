# frozen_string_literal: true

class Backdate::DestroyInteractor
  include Interactor

  delegate :params, :edition, :user, to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      update_edition
      create_timeline_entry
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(backdated_to: nil)

    edition.assign_revision(updater.next_revision, user)
           .save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(
      entry_type: :backdate_deleted,
      status: edition.status,
    )
  end
end
