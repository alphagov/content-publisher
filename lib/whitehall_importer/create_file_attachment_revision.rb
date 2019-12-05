# frozen_string_literal: true

module WhitehallImporter
  class CreateFileAttachmentRevision
    def self.call(*args)
      new(*args).call
    end

    def initialize(whitehall_file_attachment)
      @whitehall_file_attachment = whitehall_file_attachment
    end

    def call
      download_file
    end

  private

    attr_reader :whitehall_file_attachment

    def download_file
      URI.parse(whitehall_file_attachment["url"]).open
    rescue OpenURI::HTTPError
      raise WhitehallImporter::AbortImportError, "File attachment does not exist: #{whitehall_file_attachment['url']}"
    end
  end
end
