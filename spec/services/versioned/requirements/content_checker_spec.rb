# frozen_string_literal: true

RSpec.describe Versioned::Requirements::ContentChecker do
  describe "#pre_preview_issues" do
    it "returns no issues if there are none" do
      edition = build :versioned_edition
      issues = Versioned::Requirements::ContentChecker.new(edition).pre_preview_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if there is no title" do
      edition = build :versioned_edition
      revision = build :versioned_revision, title: nil
      issues = Versioned::Requirements::ContentChecker.new(edition, revision)
                                                      .pre_preview_issues

      form_message = issues.items_for(:title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.title.blank.form_message"))

      summary_message = issues.items_for(:title, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.title.blank.summary_message"))
    end

    it "returns an issue if the title is too long" do
      max_length = Versioned::Requirements::ContentChecker::TITLE_MAX_LENGTH
      edition = build :versioned_edition
      revision = build :versioned_revision, title: "a" * (max_length + 1)
      issues = Versioned::Requirements::ContentChecker.new(edition, revision)
                                                      .pre_preview_issues

      form_message = issues.items_for(:title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.title.too_long.form_message", max_length: max_length))

      summary_message = issues.items_for(:title, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.title.too_long.summary_message", max_length: max_length))
    end

    it "returns an issue if the title has newlines" do
      edition = build :versioned_edition
      revision = build :versioned_revision, title: "a\nb"
      issues = Versioned::Requirements::ContentChecker.new(edition, revision)
                                                      .pre_preview_issues

      form_message = issues.items_for(:title).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.title.multiline.form_message"))

      summary_message = issues.items_for(:title, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.title.multiline.summary_message"))
    end

    it "returns an issue if the summary is too long" do
      max_length = Versioned::Requirements::ContentChecker::SUMMARY_MAX_LENGTH
      edition = build :versioned_edition
      revision = build :versioned_revision, summary: "a" * (max_length + 1)
      issues = Versioned::Requirements::ContentChecker.new(edition, revision)
                                                      .pre_preview_issues

      form_message = issues.items_for(:summary).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.summary.too_long.form_message", max_length: max_length))

      summary_message = issues.items_for(:summary, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.summary.too_long.summary_message", max_length: max_length))
    end

    it "returns an issue if the summary has newlines" do
      edition = build :versioned_edition
      revision = build :versioned_revision, summary: "a\nb"
      issues = Versioned::Requirements::ContentChecker.new(edition, revision)
                                                      .pre_preview_issues

      form_message = issues.items_for(:summary).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.summary.multiline.form_message"))

      summary_message = issues.items_for(:summary, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.summary.multiline.summary_message"))
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues if there are none" do
      edition = build :versioned_edition, :publishable
      issues = Versioned::Requirements::ContentChecker.new(edition).pre_publish_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if the summary is blank" do
      edition = build :versioned_edition
      revision = build :versioned_revision, summary: nil
      issues = Versioned::Requirements::ContentChecker.new(edition, revision)
                                                      .pre_publish_issues

      form_message = issues.items_for(:summary).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.summary.blank.form_message"))

      summary_message = issues.items_for(:summary, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.summary.blank.summary_message"))
    end

    it "returns an issue if a field is blank" do
      document_type = build :document_type, contents: [build(:field, id: "body")]
      edition = build :versioned_edition, document_type_id: document_type.id
      issues = Versioned::Requirements::ContentChecker.new(edition).pre_publish_issues

      form_message = issues.items_for(:body).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.body.blank.form_message"))

      summary_message = issues.items_for(:body, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.body.blank.summary_message"))
    end

    it "returns an issue if a major change note is blank" do
      document = build :versioned_document, :with_live_edition
      edition = build :versioned_edition, update_type: "major", change_note: nil, document: document

      issues = Versioned::Requirements::ContentChecker.new(edition).pre_publish_issues

      form_message = issues.items_for(:change_note).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.change_note.blank.form_message"))

      summary_message = issues.items_for(:change_note, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.change_note.blank.summary_message"))
    end
  end
end
