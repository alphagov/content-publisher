# frozen_string_literal: true

RSpec.describe Requirements::ImageRevisionChecker do
  describe "#pre_preview_issues" do
    it "returns no issues if there are none" do
      image_revision = build :image_revision, alt_text: "something"
      issues = Requirements::ImageRevisionChecker.new(image_revision).pre_preview_issues
      expect(issues).to be_empty
    end

    it "returns an issue if there is no alt text" do
      image_revision = build :image_revision
      issues = Requirements::ImageRevisionChecker.new(image_revision).pre_preview_issues

      expect(issues).to have_issue(:alt_text,
                                   :blank,
                                   styles: %i[form summary],
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end

    it "returns an issue if the alt text is too long" do
      max_length = Requirements::ImageRevisionChecker::ALT_TEXT_MAX_LENGTH
      image_revision = build :image_revision, alt_text: "a" * (max_length + 1)
      issues = Requirements::ImageRevisionChecker.new(image_revision).pre_preview_issues

      expect(issues).to have_issue(:alt_text,
                                   :too_long,
                                   styles: %i[form summary],
                                   max_length: max_length,
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end

    it "returns an issue if the caption is too long" do
      max_length = Requirements::ImageRevisionChecker::CAPTION_MAX_LENGTH
      image_revision = build :image_revision, caption: "a" * (max_length + 1)
      issues = Requirements::ImageRevisionChecker.new(image_revision).pre_preview_issues

      expect(issues).to have_issue(:caption,
                                   :too_long,
                                   styles: %i[form summary],
                                   max_length: max_length,
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end

    it "returns an issue if the credit is too long" do
      max_length = Requirements::ImageRevisionChecker::CREDIT_MAX_LENGTH
      image_revision = build :image_revision, credit: "a" * (max_length + 1)
      issues = Requirements::ImageRevisionChecker.new(image_revision).pre_preview_issues

      expect(issues).to have_issue(:credit,
                                   :too_long,
                                   styles: %i[form summary],
                                   max_length: max_length,
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end
  end
end
