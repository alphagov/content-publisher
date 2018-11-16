# frozen_string_literal: true

RSpec.describe Requirements::ContentChecker do
  describe "#pre_draft_issues" do
    it "returns no issues if there are none" do
      document = build :document
      issues = Requirements::ContentChecker.new(document).pre_draft_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if there is no title" do
      document = build :document, title: nil
      issues = Requirements::ContentChecker.new(document).pre_draft_issues

      short_message = issues.items_for(:title).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.title.blank.short_message"))

      long_message = issues.items_for(:title, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.title.blank.long_message"))
    end

    it "returns an issue if the title is too long" do
      max_length = Requirements::ContentChecker::TITLE_MAX_LENGTH
      document = build :document, title: "a" * (max_length + 1)
      issues = Requirements::ContentChecker.new(document).pre_draft_issues

      short_message = issues.items_for(:title).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.title.too_long.short_message", max_length: max_length))

      long_message = issues.items_for(:title, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.title.too_long.long_message", max_length: max_length))
    end

    it "returns an issue if the title has newlines" do
      document = build :document, title: "a\nb"
      issues = Requirements::ContentChecker.new(document).pre_draft_issues

      short_message = issues.items_for(:title).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.title.multiline.short_message"))

      long_message = issues.items_for(:title, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.title.multiline.long_message"))
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues if there are none" do
      document = build :document, :with_required_content_for_publishing
      issues = Requirements::ContentChecker.new(document).pre_publish_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if the summary is blank" do
      document = build :document
      issues = Requirements::ContentChecker.new(document).pre_publish_issues

      short_message = issues.items_for(:summary).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.summary.blank.short_message"))

      long_message = issues.items_for(:summary, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.summary.blank.long_message"))
    end

    it "returns an issue if a field is blank" do
      schema = build :document_type_schema, contents: [(build :field_schema, id: "body")]
      document = build :document, document_type: schema.id
      issues = Requirements::ContentChecker.new(document).pre_publish_issues

      short_message = issues.items_for(:body).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.body.blank.short_message"))

      long_message = issues.items_for(:body, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.body.blank.long_message"))
    end

    it "returns an issue if a major change note is blank" do
      document = build :document, has_live_version_on_govuk: true
      issues = Requirements::ContentChecker.new(document).pre_publish_issues

      short_message = issues.items_for(:change_note).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.change_note.blank.short_message"))

      long_message = issues.items_for(:change_note, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.change_note.blank.long_message"))
    end
  end
end
