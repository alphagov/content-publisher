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

      form_message = issues.items_for(:title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.title.blank.form_message"))

      summary_message = issues.items_for(:title, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.title.blank.summary_message"))
    end

    it "returns an issue if the title is too long" do
      max_length = Requirements::ContentChecker::TITLE_MAX_LENGTH
      document = build :document, title: "a" * (max_length + 1)
      issues = Requirements::ContentChecker.new(document).pre_draft_issues

      form_message = issues.items_for(:title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.title.too_long.form_message", max_length: max_length))

      summary_message = issues.items_for(:title, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.title.too_long.summary_message", max_length: max_length))
    end

    it "returns an issue if the title has newlines" do
      document = build :document, title: "a\nb"
      issues = Requirements::ContentChecker.new(document).pre_draft_issues

      form_message = issues.items_for(:title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.title.multiline.form_message"))

      summary_message = issues.items_for(:title, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.title.multiline.summary_message"))
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues if there are none" do
      document = build :document, :publishable
      issues = Requirements::ContentChecker.new(document).pre_publish_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if the summary is blank" do
      document = build :document
      issues = Requirements::ContentChecker.new(document).pre_publish_issues

      form_message = issues.items_for(:summary).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.summary.blank.form_message"))

      summary_message = issues.items_for(:summary, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.summary.blank.summary_message"))
    end

    it "returns an issue if a field is blank" do
      schema = build :document_type_schema, contents: [(build :field_schema, id: "body")]
      document = build :document, document_type: schema.id
      issues = Requirements::ContentChecker.new(document).pre_publish_issues

      form_message = issues.items_for(:body).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.body.blank.form_message"))

      summary_message = issues.items_for(:body, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.body.blank.summary_message"))
    end

    it "returns an issue if a major change note is blank" do
      document = build :document, has_live_version_on_govuk: true
      issues = Requirements::ContentChecker.new(document).pre_publish_issues

      form_message = issues.items_for(:change_note).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.change_note.blank.form_message"))

      summary_message = issues.items_for(:change_note, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.change_note.blank.summary_message"))
    end
  end
end
