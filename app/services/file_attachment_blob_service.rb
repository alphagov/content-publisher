# frozen_string_literal: true

class FileAttachmentBlobService
  def initialize(revision, user)
    @revision = revision
    @user = user
  end

  def create_blob_revision(file, replacing: nil)
    mime_type = Marcel::MimeType.for(file,
                                     declared_type: file.content_type,
                                     name: file.original_filename)

    filename = unique_filename(file, replacing)
    blob = ActiveStorage::Blob.create_after_upload!(io: file,
                                                    filename: filename,
                                                    content_type: mime_type)

    FileAttachment::BlobRevision.create!(
      blob: blob,
      filename: filename,
      number_of_pages: number_of_pages(file, mime_type),
      created_by: user,
    )
  end

private

  attr_reader :revision, :user

  def unique_filename(file, replacement)
    existing_filenames = revision.file_attachment_revisions.map(&:filename)
    existing_filenames.delete(replacement.filename) if replacement
    UniqueFilenameService.new(existing_filenames).call(file.original_filename)
  end

  def number_of_pages(file, mime_type)
    return unless mime_type == "application/pdf"

    PDF::Reader.new(file.tempfile).page_count
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, OpenSSL::Cipher::CipherError
    nil
  end
end
