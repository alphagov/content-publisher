# frozen_string_literal: true

require "mini_magick"
require "digest"

RSpec.describe ImageNormaliser::TempImage do
  describe "#width" do
    it "returns the unmodified width if correctly oriented" do
      file = fixture_file_upload("files/960x640.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect(temp_image.width).to eq(960)
    end

    it "returns the modified width if a rotation is applied" do
      file = fixture_file_upload("files/640x960-rotated.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect(temp_image.width).to eq(960)
    end
  end

  describe "#height" do
    it "returns the unmodified height if correctly oriented" do
      file = fixture_file_upload("files/960x640.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect(temp_image.height).to eq(640)
    end

    it "returns the modified height if a rotation is applied" do
      file = fixture_file_upload("files/640x960-rotated.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect(temp_image.height).to eq(640)
    end
  end

  describe "#original_filename" do
    it "delegates to the raw file" do
      file = fixture_file_upload("files/640x960-rotated.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect(temp_image.original_filename).to eq(file.original_filename)
    end
  end

  describe "#mime_type" do
    it "returns the mime type of the raw file" do
      file = fixture_file_upload("files/640x960-rotated.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect(temp_image.mime_type).to eq(Marcel::MimeType.for(file))
    end
  end

  describe "#file" do
    it "returns a tempfile" do
      file = fixture_file_upload("files/960x640.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect(temp_image.file).to be_a(Tempfile)
    end

    it "does not modify the source file" do
      file = fixture_file_upload("files/640x960-rotated.jpg")
      temp_image = ImageNormaliser::TempImage.new(file)
      expect { temp_image.file }.not_to(change { Digest::SHA256.file(file.path).hexdigest })
    end

    it "fixes orientation and strips exif data" do
      source_file = fixture_file_upload("files/640x960-rotated.jpg")
      source_image = MiniMagick::Image.open(source_file.path)
      # orientation 6 means rotated 90 degrees clockwise
      expect(source_image.exif).to match(hash_including("Orientation" => "6"))

      temp_image = ImageNormaliser::TempImage.new(source_file)
      image = MiniMagick::Image.open(temp_image.file.path)

      expect(image.width).to eql(960)
      expect(image.height).to eql(640)
      expect(image.exif).to be_empty
    end
  end
end
