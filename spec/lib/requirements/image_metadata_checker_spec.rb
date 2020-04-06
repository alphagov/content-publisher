RSpec.describe Requirements::ImageMetadataChecker do
  describe "#pre_update_issues" do
    let(:checker) { described_class.new }

    it "returns no issues if there are none" do
      issues = checker.pre_update_issues(alt_text: "something")
      expect(issues).to be_empty
    end

    it "returns an issue if there is no alt text" do
      issues = checker.pre_update_issues({})
      expect(issues).to have_issue(:alt_text, :blank)
    end

    it "returns an issue if the alt text is too long" do
      max_length = Requirements::ImageMetadataChecker::ALT_TEXT_MAX_LENGTH
      issues = checker.pre_update_issues(alt_text: "a" * (max_length + 1))
      expect(issues).to have_issue(:alt_text, :too_long, max_length: max_length)
    end

    it "returns an issue if the caption is too long" do
      max_length = Requirements::ImageMetadataChecker::CAPTION_MAX_LENGTH
      issues = checker.pre_update_issues(caption: "a" * (max_length + 1))
      expect(issues).to have_issue(:caption, :too_long, max_length: max_length)
    end

    it "returns an issue if the credit is too long" do
      max_length = Requirements::ImageMetadataChecker::CREDIT_MAX_LENGTH
      issues = checker.pre_update_issues(credit: "a" * (max_length + 1))
      expect(issues).to have_issue(:credit, :too_long, max_length: max_length)
    end
  end

  describe "#pre_preview_issues" do
    let(:checker) { described_class.new }

    it "returns no issues if there are none" do
      image_revision = build :image_revision, alt_text: "something"
      issues = checker.pre_preview_issues(image_revision)
      expect(issues).to be_empty
    end

    it "returns an issue if there is no alt text" do
      image_revision = build :image_revision
      issues = checker.pre_preview_issues(image_revision)

      expect(issues).to have_issue(:alt_text,
                                   :blank,
                                   styles: %i[summary],
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end
  end
end
