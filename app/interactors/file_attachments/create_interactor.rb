# frozen_string_literal: true

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
    issues = Requirements::FileAttachmentChecker.new(file: params[:file], title: params[:title])
                                                .pre_upload_issues
    context.fail!(issues: issues) if issues.any?
  end

  def upload_attachment
    blob_revision = FileAttachmentBlobService.call(
      file: params[:file], filename: unique_filename, user: user,
    )

    context.attachment_revision = FileAttachment::Revision.create!(
      created_by: user,
      blob_revision: blob_revision,
      file_attachment: FileAttachment.create!(created_by: user),
      metadata_revision: FileAttachment::MetadataRevision.create!(
        created_by: user,
        title: params[:title],
      ),
    )
  end

  def create_timeline_entry
    TimelineEntry.create_for_revision(entry_type: :file_attachment_uploaded, edition: edition)
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.add_file_attachment(attachment_revision)
    EditEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def update_preview
    FailsafePreviewService.call(edition)
  end

  def unique_filename
    existing_filenames = edition.revision.file_attachment_revisions.map(&:filename)
    UniqueFilenameService.call(existing_filenames, params[:file].original_filename)
  end
end
