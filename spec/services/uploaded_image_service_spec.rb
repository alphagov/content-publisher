# frozen_string_literal: true

require "mini_magick"

RSpec.describe UploadedImageService do
  describe "#process" do
    context "when a valid image is uploaded" do
      it "returns a valid image" do
        uploaded_file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
        result = UploadedImageService.new(uploaded_file).process
        expect(result).to be_a(UploadedImageService::ValidImage)
        expect(result).to be_valid
      end

      it "strips exif data" do
        uploaded_file = fixture_file_upload("files/640x960-rotated.jpg", "image/jpeg")
        result = UploadedImageService.new(uploaded_file).process
        expect(result).to be_valid
        expect(MiniMagick::Image.new(result.file.path).exif).to be_empty
      end

      it "suggests crop dimensions" do
        uploaded_file = fixture_file_upload("files/1000x1000.jpg", "image/jpeg")
        result = UploadedImageService.new(uploaded_file).process
        expect(result).to be_valid
        expect(result.crop_dimensions).to eql(x: 0, y: 166, width: 1000, height: 667)
      end
    end

    context "when an incorrect file type is provided" do
      it "returns an invalid image" do
        uploaded_file = fixture_file_upload("files/text-file.txt", "text/plain")
        result = UploadedImageService.new(uploaded_file).process
        expect(result).to be_a(UploadedImageService::InvalidImage)
        expect(result).not_to be_valid
        expect(result.errors).to include("Expected a jpg, png or gif image")
      end
    end

    context "when a file bigger than the max size is uploaded" do
      it "has a file size error" do
        uploaded_file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
        allow(uploaded_file).to receive(:size).and_return(30.megabytes)
        result = UploadedImageService.new(uploaded_file).process
        expect(result.errors)
          .to include("Image uploads must be less than 20 MB in filesize")
      end
    end

    context "when a file smaller than the minimum dimensions is uploaded" do
      it "has a dimensions error" do
        uploaded_file = fixture_file_upload("files/100x100.jpg", "image/jpeg")
        result = UploadedImageService.new(uploaded_file).process
        expect(result.errors)
          .to include("Images must have dimensions of at least 960 x 640 pixels")
      end
    end
  end
end
