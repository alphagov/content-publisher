# frozen_string_literal: true

module WhitehallImporter
  class CreateImageRevision
    attr_reader :whitehall_image

    def self.call(*args)
      new(*args).call
    end

    def initialize(whitehall_image)
      @whitehall_image = whitehall_image
    end

    def call
      temp_image = normalise_image(download_file)
      blob_revision = create_blob_revision(temp_image)
      Image::Revision.create!(
        image: Image.new,
        metadata_revision: Image::MetadataRevision.new(
          caption: whitehall_image["caption"],
          alt_text: whitehall_image["alt_text"],
        ),
        blob_revision: blob_revision,
      )
    end

  private

    def download_file
      URI.parse(whitehall_image["url"]).open
    end

    def create_blob_revision(temp_image)
      ImageBlobService.call(
        temp_image: temp_image,
        filename: File.basename(whitehall_image["url"]),
      )
    end

    def normalise_image(file)
      ImageNormaliser.new(file).normalise
    end
  end
end
