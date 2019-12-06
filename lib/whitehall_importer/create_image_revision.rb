# frozen_string_literal: true

module WhitehallImporter
  class CreateImageRevision
    attr_reader :record, :whitehall_image, :filenames

    delegate :document to: :record

    def self.call(*args)
      new(*args).call
    end

    def initialize(record, whitehall_image, filenames = [])
      @record = record
      @whitehall_image = whitehall_image
      @filenames = filenames
    end

    def call
      temp_image = normalise_image(download_file)
      blob_revision = create_blob_revision(temp_image)
      revision = Image::Revision.create!(
        image: Image.new,
        metadata_revision: Image::MetadataRevision.new(
          caption: whitehall_image["caption"],
          alt_text: whitehall_image["alt_text"],
        ),
        blob_revision: blob_revision,
      )
      WhitehallImportedAsset.new(
        whitehall_import: record,
        file_attachment_revision: revision,
        original_asset_url: whitehall_image["url"],
        variants: whitehall_image["variants"],
      )
    end

  private

    def download_file
      file = URI.parse(whitehall_image["url"]).open
      if file.is_a?(StringIO)
        # files less than 10 KB return StringIO (we have to manually cast to a tempfile)
        Tempfile.new.tap { |tmp| File.write(tmp.path, file.string) }
      else
        file
      end
    rescue OpenURI::HTTPError
      raise WhitehallImporter::AbortImportError, "Image does not exist: #{whitehall_image['url']}"
    end

    def create_blob_revision(temp_image)
      ImageBlobService.call(
        temp_image: temp_image,
        filename: UniqueFilenameService.call(
          filenames,
          File.basename(whitehall_image["url"]),
        ),
      )
    end

    def normalise_image(file)
      upload_checker = Requirements::ImageUploadChecker.new(file)
      abort_on_issue(upload_checker.issues)
      normaliser = ImageNormaliser.new(file)
      image = normaliser.normalise
      abort_on_issue(normaliser.issues)

      image
    end

    def abort_on_issue(issues)
      return if issues.empty?

      raise WhitehallImporter::AbortImportError, issues.first.message(style: "form")
    end
  end
end
