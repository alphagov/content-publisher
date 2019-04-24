# frozen_string_literal: true

class FileAttachmentUploadService
  def initialize(file, revision, title)
    @file = file
    @revision = revision
    @title = title
  end

  def call(user)
    file_attachment = FileAttachment.create!(created_by: user)

    blob = ActiveStorage::Blob.create_after_upload!(
      io: file,
      filename: filename,
      content_type: Marcel::MimeType.for(file),
    )

    blob_revision = FileAttachment::BlobRevision.new(
      blob: blob, created_by: user, filename: filename, size: file.size,
    )

    metadata_revision = FileAttachment::MetadataRevision.new(
      created_by: user, title: title,
    )

    FileAttachment::Revision.create!(
      file_attachment: file_attachment,
      created_by: user,
      blob_revision: blob_revision,
      metadata_revision: metadata_revision,
    )
  end

private

  attr_reader :file, :revision, :title

  def filename
    existing_filenames = revision.file_attachment_revisions.map(&:filename)
    UniqueFilenameService.new(existing_filenames).call(file.original_filename)
  end
end
