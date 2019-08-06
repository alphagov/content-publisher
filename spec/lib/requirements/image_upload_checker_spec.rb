# frozen_string_literal: true

RSpec.describe Requirements::ImageUploadChecker do
  describe "#errors" do
    it "returns no issues if there are none" do
      file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
      issues = Requirements::ImageUploadChecker.new(file).issues
      expect(issues).to be_empty
    end

    it "returns an issue when no image is specified" do
      issues = Requirements::ImageUploadChecker.new(nil).issues
      expect(issues).to have_issue(:image_upload, :no_file)
    end

    it "returns an issue when an unsupported file type is provided" do
      file = fixture_file_upload("files/text-file.txt", "text/plain")
      issues = Requirements::ImageUploadChecker.new(file).issues
      expect(issues).to have_issue(:image_upload, :unsupported_type)
    end

    it "returns an issue when a file bigger than the max size is provided" do
      file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
      allow(file).to receive(:size).and_return(30.megabytes)
      issues = Requirements::ImageUploadChecker.new(file).issues
      expect(issues).to have_issue(:image_upload, :too_big, max_size: "20 MB")
    end

    it "returns an issue when a file smaller than the minimum dimensions is provided" do
      file = fixture_file_upload("files/100x100.jpg", "image/jpeg")
      issues = Requirements::ImageUploadChecker.new(file).issues
      expect(issues).to have_issue(:image_upload, :too_small, width: Image::WIDTH, height: Image::HEIGHT)
    end

    it "returns an issues when a file with multiple frames is provided (animated gif)" do
      file = fixture_file_upload("files/animated-gif.gif", "image/gif")
      issues = Requirements::ImageUploadChecker.new(file).issues
      expect(issues).to have_issue(:image_upload, :animated_image)
    end
  end
end
