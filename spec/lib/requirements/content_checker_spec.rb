# frozen_string_literal: true

RSpec.describe Requirements::ContentChecker do
  describe "#pre_preview_issues" do
    it "returns no issues if there are none" do
      edition = build :edition
      issues = Requirements::ContentChecker.new(edition).pre_preview_issues
      expect(issues).to be_empty
    end

    it "returns an issue if there is no title" do
      edition = build :edition
      revision = build :revision, title: nil
      issues = Requirements::ContentChecker.new(edition, revision).pre_preview_issues
      expect(issues).to have_issue(:title, :blank, styles: %i[form summary])
    end

    it "returns an issue if the title is too long" do
      edition = build :edition
      max_length = Requirements::ContentChecker::TITLE_MAX_LENGTH
      revision = build :revision, title: "a" * (max_length + 1)
      issues = Requirements::ContentChecker.new(edition, revision).pre_preview_issues
      expect(issues).to have_issue(:title, :too_long, styles: %i[form summary], max_length: max_length)
    end

    it "returns an issue if the title has newlines" do
      edition = build :edition
      revision = build :revision, title: "a\nb"
      issues = Requirements::ContentChecker.new(edition, revision).pre_preview_issues
      expect(issues).to have_issue(:title, :multiline, styles: %i[form summary])
    end

    it "returns an issue if the summary is too long" do
      edition = build :edition
      max_length = Requirements::ContentChecker::SUMMARY_MAX_LENGTH
      revision = build :revision, summary: "a" * (max_length + 1)
      issues = Requirements::ContentChecker.new(edition, revision).pre_preview_issues
      expect(issues).to have_issue(:summary, :too_long, styles: %i[form summary], max_length: max_length)
    end

    it "returns an issue if the summary has newlines" do
      edition = build :edition
      revision = build :revision, summary: "a\nb"
      issues = Requirements::ContentChecker.new(edition, revision).pre_preview_issues
      expect(issues).to have_issue(:summary, :multiline, styles: %i[form summary])
    end

    it "returns an issue if the a govspeak field contains forbidden HTML" do
      body_field = build :field, id: "body", type: "govspeak"
      document_type = build :document_type, contents: [body_field]
      edition = build :edition, document_type_id: document_type.id
      revision = build :revision, contents: { body: "<script>alert('hi')</script>" }
      issues = Requirements::ContentChecker.new(edition, revision).pre_preview_issues
      expect(issues).to have_issue(:body, :invalid_govspeak, styles: %i[form summary])
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues if there are none" do
      edition = build :edition, :publishable
      issues = Requirements::ContentChecker.new(edition).pre_publish_issues
      expect(issues).to be_empty
    end

    it "returns an issue if the summary is blank" do
      edition = build :edition
      revision = build :revision, summary: nil
      issues = Requirements::ContentChecker.new(edition, revision).pre_publish_issues
      expect(issues).to have_issue(:summary, :blank, styles: %i[form summary])
    end

    it "returns an issue if a field is blank" do
      document_type = build :document_type, contents: [build(:field, id: "body")]
      edition = build :edition, document_type_id: document_type.id
      issues = Requirements::ContentChecker.new(edition).pre_publish_issues
      expect(issues).to have_issue(:body, :blank, styles: %i[form summary])
    end

    it "returns an issue if a major change note is blank" do
      document = build :document, :with_live_edition
      edition = build :edition, update_type: "major", change_note: nil, document: document
      issues = Requirements::ContentChecker.new(edition).pre_publish_issues
      expect(issues).to have_issue(:change_note, :blank, styles: %i[form summary])
    end
  end
end
