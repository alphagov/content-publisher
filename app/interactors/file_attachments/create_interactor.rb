class FileAttachments::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      upload_attachment

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

  def check_for_issues
    issues = Requirements::Form::FileAttachmentUploadChecker.call(file: params[:file],
                                                                  title: params[:title])

    issues.create(:file_attachment_upload, :no_file) if params[:file].blank?
    context.fail!(issues:) if issues.any?
  end

  def upload_attachment
    blob_revision = CreateFileAttachmentBlobService.call(
      file: params[:file], filename: unique_filename, user:,
    )

    context.attachment_revision = FileAttachment::Revision.create!(
      created_by: user,
      blob_revision:,
      file_attachment: FileAttachment.create!(created_by: user),
      metadata_revision: FileAttachment::MetadataRevision.create!(
        created_by: user,
        title: params[:title],
      ),
    )
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :file_attachment_uploaded, edition:)
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.add_file_attachment(attachment_revision)
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def update_preview
    FailsafeDraftPreviewService.call(edition)
  end

  def unique_filename
    existing_filenames = edition.revision.file_attachment_revisions.map(&:filename)
    GenerateUniqueFilenameService.call(filename: params[:file].original_filename,
                                       existing_filenames:)
  end
end
