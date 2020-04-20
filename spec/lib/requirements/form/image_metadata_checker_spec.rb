RSpec.describe Requirements::Form::ImageMetadataChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      issues = described_class.call(alt_text: "something")
      expect(issues).to be_empty
    end

    it "returns an issue if there is no alt text" do
      issues = described_class.call({})
      expect(issues).to have_issue(:image_alt_text, :blank)
    end

    it "returns an issue if the alt text is too long" do
      max_length = Requirements::Form::ImageMetadataChecker::ALT_TEXT_MAX_LENGTH
      issues = described_class.call(alt_text: "a" * (max_length + 1))
      expect(issues).to have_issue(:image_alt_text, :too_long, max_length: max_length)
    end

    it "returns an issue if the caption is too long" do
      max_length = Requirements::Form::ImageMetadataChecker::CAPTION_MAX_LENGTH
      issues = described_class.call(caption: "a" * (max_length + 1))
      expect(issues).to have_issue(:image_caption, :too_long, max_length: max_length)
    end

    it "returns an issue if the credit is too long" do
      max_length = Requirements::Form::ImageMetadataChecker::CREDIT_MAX_LENGTH
      issues = described_class.call(credit: "a" * (max_length + 1))
      expect(issues).to have_issue(:image_credit, :too_long, max_length: max_length)
    end
  end
end
