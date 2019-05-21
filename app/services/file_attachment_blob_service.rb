# frozen_string_literal: true

class FileAttachmentBlobService
  attr_reader :file, :revision, :replacement

  def initialize(file:, revision:, replacement: nil)
    @file = file
    @revision = revision
    @replacement = replacement
  end

  def blob_id
    blob.id
  end

  def filename
    @filename ||= begin
      existing_filenames = revision.file_attachment_revisions.map(&:filename)
      existing_filenames.delete(replacement.filename) if replacement
      UniqueFilenameService.new(existing_filenames).call(file.original_filename)
    end
  end

  def number_of_pages
    return unless mime_type == "application/pdf"

    PDF::Reader.new(file.tempfile).page_count
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, OpenSSL::Cipher::CipherError
    nil
  end

private

  def blob
    @blob ||= ActiveStorage::Blob.create_after_upload!(
      io: file,
      filename: filename,
      content_type: mime_type,
    )
  end

  def mime_type
    @mime_type ||= Marcel::MimeType.for(file,
                                        declared_type: file.content_type,
                                        name: file.original_filename)
  end
end
