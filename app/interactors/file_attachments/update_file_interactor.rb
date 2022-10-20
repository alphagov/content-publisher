class FileAttachments::UpdateFileInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :file_attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_file_attachment
      check_for_issues

      update_file_attachment
      update_edition

      create_timeline_entry
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document: params[:document])
    assert_edition_state(edition, &:editable?)
  end

  def find_file_attachment
    context.file_attachment_revision = edition.file_attachment_revisions
                                              .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def check_for_issues
    issues = Requirements::Form::FileAttachmentUploadChecker.call(file: attachment_params[:file],
                                                                  title: attachment_params[:title])
    context.fail!(issues:) if issues.any?
  end

  def update_file_attachment
    updater = Versioning::FileAttachmentRevisionUpdater.new(file_attachment_revision, user)
    revision_attributes = attachment_params.slice(:title)
    revision_attributes[:blob_revision] = blob_revision(attachment_params[:file]) if attachment_params[:file]
    updater.assign(revision_attributes)

    context.file_attachment_revision = updater.next_revision
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_file_attachment(file_attachment_revision)

    context.fail!(unchanged: true) unless updater.changed?

    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :file_attachment_updated,
                                      edition:)
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end

  def attachment_params
    params.require(:file_attachment).permit(:file, :title)
  end

  def blob_revision(file)
    CreateFileAttachmentBlobService.call(
      file:, filename: unique_filename(file), user:,
    )
  end

  def unique_filename(file)
    existing_filenames = edition.revision.file_attachment_revisions.map(&:filename)
    existing_filenames.delete(file_attachment_revision.filename)
    GenerateUniqueFilenameService.call(filename: file.original_filename,
                                       existing_filenames:)
  end
end
