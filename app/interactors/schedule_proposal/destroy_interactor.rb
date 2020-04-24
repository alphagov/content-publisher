class ScheduleProposal::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :edition,
           :user,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      clear_proposed_time
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def clear_proposed_time
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(proposed_publish_time: nil)

    context.fail! unless updater.changed?

    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end
end
