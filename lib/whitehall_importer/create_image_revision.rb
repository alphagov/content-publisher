module WhitehallImporter
  class CreateImageRevision
    attr_reader :document_import, :whitehall_image, :filenames

    def self.call(...)
      new(...).call
    end

    def initialize(document_import, whitehall_image, filenames = [])
      @document_import = document_import
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
      record_assets(revision)
      revision
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
      CreateImageBlobService.call(
        temp_image: temp_image,
        filename: GenerateUniqueFilenameService.call(
          existing_filenames: filenames,
          filename: File.basename(whitehall_image["url"]),
        ),
      )
    end

    def normalise_image(file)
      issues = Requirements::Form::ImageUploadChecker.call(file)
      abort_on_issue(issues)

      stripped_image = MiniMagick::Image.open(file.path).strip
      normaliser = ImageNormaliser.new(stripped_image)
      image = normaliser.normalise
      abort_on_issue(normaliser.issues)

      image
    end

    def record_assets(revision)
      WhitehallMigration::AssetImport.create!(
        document_import: document_import,
        image_revision: revision,
        original_asset_url: whitehall_image["url"],
      )
      whitehall_image["variants"].each do |variant, url|
        WhitehallMigration::AssetImport.create!(
          document_import: document_import,
          image_revision: revision,
          original_asset_url: url,
          variant: variant,
        )
      end
    end

    def abort_on_issue(issues)
      return if issues.empty?

      raise WhitehallImporter::AbortImportError, issues.first.message(style: "form")
    end
  end
end
