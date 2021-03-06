RSpec.describe Requirements::Form::ImageUploadChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      file = fixture_file_upload("960x640.jpg", "image/jpeg")
      issues = described_class.call(file)
      expect(issues).to be_empty
    end

    it "returns an issue when no image is specified" do
      issues = described_class.call(nil)
      expect(issues).to have_issue(:image_upload, :no_file)
    end

    it "returns an issue when an unsupported file type is provided" do
      file = fixture_file_upload("text-file-74bytes.txt", "text/plain")
      issues = described_class.call(file)
      expect(issues).to have_issue(:image_upload, :unsupported_type)
    end

    it "returns an issue when a file bigger than the max size is provided" do
      file = fixture_file_upload("960x640.jpg", "image/jpeg")
      allow(file).to receive(:size).and_return(30.megabytes)
      issues = described_class.call(file)
      expect(issues).to have_issue(:image_upload, :too_big, max_size: "20 MB")
    end
  end
end
