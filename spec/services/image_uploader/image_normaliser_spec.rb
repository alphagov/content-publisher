# frozen_string_literal: true

require "mini_magick"

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

  describe "#normalise" do
    it "returns the image file" do
      temp = Tempfile.new
      temp.write(file_fixture("960x640.jpg").read)

      normaliser = ImageUploader::ImageNormaliser.new(temp.path)
      expect(normaliser.normalise).to be_a(MiniMagick::Image)
    end

    it "fixes orientation and strips exif data" do
      source_path = file_fixture("640x960-rotated.jpg")
      temp = Tempfile.new
      temp.write(source_path.read)

      source_image = MiniMagick::Image.new(source_path)
      # orientation 6 means rotated 90 degrees clockwise
      expect(source_image.exif).to match(hash_including("Orientation" => "6"))

      normaliser = ImageUploader::ImageNormaliser.new(temp.path)
      image = normaliser.normalise
      expect(image.width).to eql(960)
      expect(image.height).to eql(640)
      expect(image.exif).to be_empty
    end
  end
end
