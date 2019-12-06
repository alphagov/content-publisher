# frozen_string_literal: true

class FileAttachmentBlobService < ApplicationService
  def initialize(file:, filename:, user: nil)
    @file = file
    @filename = filename
    @user = user
  end

  def call
    blob = ActiveStorage::Blob.create_after_upload!(io: file,
                                                    filename: filename,
                                                    content_type: mime_type)

    FileAttachment::BlobRevision.create!(
      blob: blob,
      filename: filename,
      number_of_pages: number_of_pages,
      created_by: user,
      asset: FileAttachment::Asset.new,
    )
  end

private

  attr_reader :file, :filename, :user

  def mime_type
    @mime_type ||= Marcel::MimeType.for(file,
                                        declared_type: file.content_type,
                                        name: file.original_filename)
  end

  def number_of_pages
    return unless mime_type == "application/pdf"

    PDF::Reader.new(file.tempfile).page_count
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, OpenSSL::Cipher::CipherError
    nil
  end
end
