# frozen_string_literal: true

class FileAttachmentBlobService
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def blob_id
    blob.id
  end

  def blob_filename
    blob[:filename]
  end

private

  def blob
    @blob ||= ActiveStorage::Blob.create_after_upload!(
      io: file,
      filename: file.original_filename,
      content_type: mime_type,
    )
  end

  def mime_type
    Marcel::MimeType.for(file,
                         declared_type: file.content_type,
                         name: file.original_filename)
  end
end
