# frozen_string_literal: true

module WhitehallImporter
  class CreateFileAttachmentRevision
    def self.call(*args)
      new(*args).call
    end

    def initialize(whitehall_file_attachment, existing_filenames = [])
      @whitehall_file_attachment = whitehall_file_attachment
      @existing_filenames = existing_filenames
    end

    def call
      decorated_file = AttachmentFileDecorator.new(download_file, unique_filename)

      create_blob_revision(decorated_file)
    end

  private

    attr_reader :whitehall_file_attachment, :existing_filenames

    def download_file
      URI.parse(whitehall_file_attachment["url"]).open
    rescue OpenURI::HTTPError
      raise WhitehallImporter::AbortImportError, "File attachment does not exist: #{whitehall_file_attachment['url']}"
    end

    def create_blob_revision(file)
      FileAttachmentBlobService.call(
        file: file,
        filename: unique_filename,
      )
    end

    def unique_filename
      @unique_filename ||= UniqueFilenameService.call(
        existing_filenames,
        File.basename(whitehall_file_attachment["url"]),
      )
    end
  end

  class AttachmentFileDecorator < SimpleDelegator
    attr_reader :original_filename

    def initialize(tmp_file, original_filename)
      super(tmp_file)
      @original_filename = original_filename
    end

    def content_type
      nil
    end
  end
end
