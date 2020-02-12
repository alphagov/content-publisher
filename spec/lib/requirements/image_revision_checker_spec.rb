# frozen_string_literal: true

RSpec.describe Requirements::ImageRevisionChecker do
  describe "#pre_update_issues" do
    let(:image_revision) { build :image_revision }
    let(:checker) { Requirements::ImageRevisionChecker.new(image_revision) }

    it "returns no issues if there are none" do
      issues = checker.pre_update_issues(alt_text: "something")
      expect(issues).to be_empty
    end

    it "returns an issue if there is no alt text" do
      issues = checker.pre_update_issues({})

      expect(issues).to have_issue(:alt_text,
                                   :blank,
                                   styles: %i[form summary],
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end

    it "returns an issue if the alt text is too long" do
      max_length = Requirements::ImageRevisionChecker::ALT_TEXT_MAX_LENGTH
      issues = checker.pre_update_issues(alt_text: "a" * (max_length + 1))

      expect(issues).to have_issue(:alt_text,
                                   :too_long,
                                   styles: %i[form summary],
                                   max_length: max_length,
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end

    it "returns an issue if the caption is too long" do
      max_length = Requirements::ImageRevisionChecker::CAPTION_MAX_LENGTH
      issues = checker.pre_update_issues(caption: "a" * (max_length + 1))

      expect(issues).to have_issue(:caption,
                                   :too_long,
                                   styles: %i[form summary],
                                   max_length: max_length,
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end

    it "returns an issue if the credit is too long" do
      max_length = Requirements::ImageRevisionChecker::CREDIT_MAX_LENGTH
      issues = checker.pre_update_issues(credit: "a" * (max_length + 1))

      expect(issues).to have_issue(:credit,
                                   :too_long,
                                   styles: %i[form summary],
                                   max_length: max_length,
                                   filename: image_revision.filename,
                                   image_revision: image_revision)
    end
  end

  describe "#pre_preview_issues" do
    it "delegates to #pre_update_issues" do
      params = { alt_text: "alt", caption: "caption", credit: "credit" }
      image_revision = build :image_revision, params

      checker = Requirements::ImageRevisionChecker.new(image_revision)
      expect(checker).to receive(:pre_update_issues).with(params)
      checker.pre_preview_issues
    end
  end
end
