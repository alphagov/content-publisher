# frozen_string_literal: true

require "mini_magick"

RSpec.describe ImageUploader do
  describe "#upload" do
    it "creates an image model for a document" do
      uploaded_file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
      document = create(:document)
      uploader = ImageUploader.new(uploaded_file)
      expect(uploader.upload(document)).to be_an_instance_of(Image)
    end

    it "sets the filename on the image" do
      uploaded_file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
      image = ImageUploader.new(uploaded_file).upload(create(:document))
      expect(image.filename).to eq("960x640.jpg")

      file_object = File.open(file_fixture("1000x1000.jpg"))
      image = ImageUploader.new(file_object).upload(create(:document))
      expect(image.filename).to eq("1000x1000.jpg")
    end

    it "strips exif data" do
      uploaded_file = fixture_file_upload("files/640x960-rotated.jpg", "image/jpeg")
      image = ImageUploader.new(uploaded_file).upload(create(:document))
      tempfile = Tempfile.new.tap do |file|
        file.binmode
        file.write(image.blob.download)
      end
      expect(MiniMagick::Image.new(tempfile.path).exif).to be_empty
    end

    it "suggests crop dimensions" do
      uploaded_file = fixture_file_upload("files/1000x1000.jpg", "image/jpeg")
      image = ImageUploader.new(uploaded_file).upload(create(:document))
      expect(image.crop_x).to be(0)
      expect(image.crop_y).to be(166)
      expect(image.crop_width).to be(1000)
      expect(image.crop_height).to be(667)
    end
  end
end
