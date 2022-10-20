class FileAttachments::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_remove_attachment
      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def find_and_remove_attachment
    context.attachment_revision = edition.file_attachment_revisions
      .find_by!(file_attachment_id: params[:file_attachment_id])

    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.remove_file_attachment(attachment_revision)
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :file_attachment_deleted, edition:)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end
end
