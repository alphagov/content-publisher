# frozen_string_literal: true

require "mini_magick"
require "digest"

RSpec.describe ImageUploader::ImageNormaliser do
  describe "#dimensions" do
    context "when given an image without an orientation" do
      it "returns the dimensions" do
        path = file_fixture("960x640.jpg")

        normaliser = ImageUploader::ImageNormaliser.new(path)
        expect(normaliser.dimensions).to eql(width: 960, height: 640)
      end
    end

    context "when given an image with orientation" do
      it "returns the normalised dimensions" do
        path = file_fixture("640x960-rotated.jpg")

        normaliser = ImageUploader::ImageNormaliser.new(path)
        expect(normaliser.dimensions).to eql(width: 960, height: 640)
      end
    end
  end

  describe "#normalised_file" do
    it "returns a tempfile" do
      normaliser = ImageUploader::ImageNormaliser.new(file_fixture("960x640.jpg"))
      expect(normaliser.normalised_file).to be_a(Tempfile)
    end

    it "does not modify the source file" do
      path = file_fixture("640x960-rotated.jpg")
      normaliser = ImageUploader::ImageNormaliser.new(path)
      expect { normaliser.normalised_file }
        .not_to(change { Digest::SHA256.file(path).hexdigest })
    end

    it "fixes orientation and strips exif data" do
      source_path = file_fixture("640x960-rotated.jpg")
      source_image = MiniMagick::Image.open(source_path)
      # orientation 6 means rotated 90 degrees clockwise
      expect(source_image.exif).to match(hash_including("Orientation" => "6"))

      normaliser = ImageUploader::ImageNormaliser.new(source_path)
      image = MiniMagick::Image.open(normaliser.normalised_file.path)

      expect(image.width).to eql(960)
      expect(image.height).to eql(640)
      expect(image.exif).to be_empty
    end
  end
end
