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
      form_message = issues.items_for(:image_upload).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.image_upload.no_file.form_message"))
    end

    it "returns an issue when an unsupported file type is provided" do
      file = fixture_file_upload("files/text-file.txt", "text/plain")
      issues = Requirements::ImageUploadChecker.new(file).issues
      form_message = issues.items_for(:image_upload).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.image_upload.unsupported_type.form_message"))
    end

    it "returns an issue when a file bigger than the max size is provided" do
      file = fixture_file_upload("files/960x640.jpg", "image/jpeg")
      allow(file).to receive(:size).and_return(30.megabytes)
      issues = Requirements::ImageUploadChecker.new(file).issues
      form_message = issues.items_for(:image_upload).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.image_upload.too_big.form_message", max_size: "20 MB"))
    end

    it "returns an issue when a file smaller than the minimum dimensions is provided" do
      file = fixture_file_upload("files/100x100.jpg", "image/jpeg")
      issues = Requirements::ImageUploadChecker.new(file).issues
      form_message = issues.items_for(:image_upload).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.image_upload.too_small.form_message", width: Image::WIDTH, height: Image::HEIGHT))
    end

    it "returns an issues when a file with multiple frames is provided (animated gif)" do
      file = fixture_file_upload("files/animated-gif.gif", "image/gif")
      issues = Requirements::ImageUploadChecker.new(file).issues
      form_message = issues.items_for(:image_upload).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.image_upload.animated_image.form_message"))
    end
  end
end
