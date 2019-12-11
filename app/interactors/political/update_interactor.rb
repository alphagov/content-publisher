# frozen_string_literal: true

class Political::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :next_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      create_next_revision
      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def create_next_revision
    updater = Versioning::RevisionUpdater.new(edition.revision, user)

    updater.assign(editor_political: params[:political] == "yes")
    EditEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(
      entry_type: :political_status_changed,
      revision: edition.revision,
      edition: edition,
      created_by: user,
    )
  end

  def update_preview
    FailsafePreviewService.call(edition)
  end
end
