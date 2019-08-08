# frozen_string_literal: true

class FileAttachmentBlobService < ApplicationService
  def initialize(revision, user, file, replacing: nil)
    @revision = revision
    @user = user
    @file = file
    @replacing = replacing
  end

  def call
    blob = ActiveStorage::Blob.create_after_upload!(io: file,
                                                    filename: unique_filename,
                                                    content_type: mime_type)

    FileAttachment::BlobRevision.create!(
      blob: blob,
      filename: unique_filename,
      number_of_pages: number_of_pages,
      created_by: user,
      asset: FileAttachment::Asset.new,
    )
  end

private

  attr_reader :revision, :user, :file, :replacing

  def mime_type
    @mime_type ||= Marcel::MimeType.for(file,
                                        declared_type: file.content_type,
                                        name: file.original_filename)
  end

  def unique_filename
    existing_filenames = revision.file_attachment_revisions.map(&:filename)
    existing_filenames.delete(replacing.filename) if replacing
    UniqueFilenameService.call(existing_filenames, file.original_filename)
  end

  def number_of_pages
    return unless mime_type == "application/pdf"

    PDF::Reader.new(file.tempfile).page_count
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, OpenSSL::Cipher::CipherError
    nil
  end
end
