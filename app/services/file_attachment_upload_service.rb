# frozen_string_literal: true

class FileAttachmentUploadService
  attr_reader :file, :revision, :title

  def initialize(file, revision, title)
    @file = file
    @revision = revision
    @title = title
  end

  def call(user)
    file_attachment = FileAttachment.create!(created_by: user)

    blob_service = FileAttachmentBlobService.new(file: file, revision: revision)

    blob_revision = FileAttachment::BlobRevision.new(
      blob_id: blob_service.blob_id,
      created_by: user,
      filename: blob_service.filename,
      number_of_pages: blob_service.number_of_pages,
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
end
