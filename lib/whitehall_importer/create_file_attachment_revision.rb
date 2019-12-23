# frozen_string_literal: true

module WhitehallImporter
  class CreateFileAttachmentRevision
    def self.call(*args)
      new(*args).call
    end

    def initialize(document_import, whitehall_file_attachment, existing_filenames = [])
      @document_import = document_import
      @whitehall_file_attachment = whitehall_file_attachment
      @existing_filenames = existing_filenames
    end

    def call
      check_whitehall_file_attachment_type

      decorated_file = AttachmentFileDecorator.new(download_file, unique_filename)
      check_file_requirements(decorated_file)

      blob_revision = create_blob_revision(decorated_file)
      revision = FileAttachment::Revision.create!(
        blob_revision: blob_revision,
        file_attachment: FileAttachment.create!,
        metadata_revision: FileAttachment::MetadataRevision.create!(
          title: whitehall_file_attachment["title"],
        ),
      )
      record_assets(revision)
      revision
    end

  private

    attr_reader :document_import, :whitehall_file_attachment, :existing_filenames

    def download_file
      URI.parse(whitehall_file_attachment["url"]).open
    rescue OpenURI::HTTPError
      raise WhitehallImporter::AbortImportError, "File attachment does not exist: #{whitehall_file_attachment['url']}"
    end

    def unique_filename
      @unique_filename ||= UniqueFilenameService.call(
        existing_filenames,
        File.basename(whitehall_file_attachment["url"]),
      )
    end

    def create_blob_revision(decorated_file)
      FileAttachmentBlobService.call(
        file: decorated_file,
        filename: unique_filename,
      )
    end

    def check_file_requirements(decorated_file)
      upload_checker = Requirements::FileAttachmentChecker.new(
        file: decorated_file, title: whitehall_file_attachment["title"],
      ).pre_upload_issues

      abort_on_issue(upload_checker.issues)
    end

    def check_whitehall_file_attachment_type
      return if whitehall_file_attachment["type"] == "FileAttachment"

      raise WhitehallImporter::AbortImportError, "Unsupported file attachment: #{whitehall_file_attachment['type']}"
    end

    def record_assets(revision)
      WhitehallMigration::AssetImport.create!(
        document_import: document_import,
        file_attachment_revision: revision,
        original_asset_url: whitehall_file_attachment["url"],
      )
      whitehall_file_attachment["variants"].each do |variant, metadata|
        WhitehallMigration::AssetImport.create!(
          document_import: document_import,
          file_attachment_revision: revision,
          original_asset_url: metadata["url"],
          variant: variant,
        )
      end
    end

    def abort_on_issue(issues)
      return if issues.empty?

      raise WhitehallImporter::AbortImportError, issues.first.message(style: "form")
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
