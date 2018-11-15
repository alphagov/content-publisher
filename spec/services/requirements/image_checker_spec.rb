# frozen_string_literal: true

RSpec.describe Requirements::ImageChecker do
  describe "#pre_draft_issues" do
    it "returns no issues if there are none" do
      image = build :image, alt_text: "something"
      issues = Requirements::ImageChecker.new(image).pre_draft_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if there is no alt text" do
      image = build :image
      issues = Requirements::ImageChecker.new(image).pre_draft_issues

      short_message = issues.items_for(:alt_text).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.alt_text.blank.short_message"))

      long_message = issues.items_for(:alt_text, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.alt_text.blank.long_message", filename: image.filename))
    end

    it "returns an issue if the alt text is too long" do
      max_length = Requirements::ImageChecker::ALT_TEXT_MAX_LENGTH
      image = build :image, alt_text: "a" * (max_length + 1)
      issues = Requirements::ImageChecker.new(image).pre_draft_issues

      short_message = issues.items_for(:alt_text).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.alt_text.too_long.short_message", max_length: max_length))

      long_message = issues.items_for(:alt_text, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.alt_text.too_long.long_message", max_length: max_length, filename: image.filename))
    end

    it "returns an issue if the caption is too long" do
      max_length = Requirements::ImageChecker::CAPTION_MAX_LENGTH
      image = build :image, caption: "a" * (max_length + 1)
      issues = Requirements::ImageChecker.new(image).pre_draft_issues

      short_message = issues.items_for(:caption).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.caption.too_long.short_message", max_length: max_length))

      long_message = issues.items_for(:caption, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.caption.too_long.long_message", max_length: max_length, filename: image.filename))
    end
  end
end
