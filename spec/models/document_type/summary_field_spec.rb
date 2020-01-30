# frozen_string_literal: true

RSpec.describe DocumentType::SummaryField do
  describe "#payload" do
    it "returns a hash with a 'description' / summary" do
      edition = build(:edition, summary: "document summary")
      payload = subject.payload(edition)
      expect(payload).to eq(description: "document summary")
    end
  end

  describe "#updater_params" do
    it "returns a hash of the stripped summary" do
      edition = build :edition
      params = ActionController::Parameters.new(revision: { summary: "  summary" })
      updater_params = subject.updater_params(edition, params)
      expect(updater_params).to eq(summary: "summary")
    end
  end

  describe "#pre_preview_issues" do
    let(:edition) { build :edition }

    it "returns no issues if there are none" do
      issues = subject.pre_preview_issues(edition, edition.revision)
      expect(issues).to be_empty
    end

    it "returns an issue if the summary is too long" do
      max_length = DocumentType::SummaryField::SUMMARY_MAX_LENGTH
      revision = build :revision, summary: "a" * (max_length + 1)
      issues = subject.pre_preview_issues(edition, revision)
      expect(issues).to have_issue(:summary, :too_long, styles: %i[form summary], max_length: max_length)
    end

    it "returns an issue if the summary has newlines" do
      revision = build :revision, summary: "a\nb"
      issues = subject.pre_preview_issues(edition, revision)
      expect(issues).to have_issue(:summary, :multiline, styles: %i[form summary])
    end
  end

  describe "#pre_publish_issues" do
    let(:edition) { build :edition, summary: "a summary" }

    it "returns no issues if there are none" do
      issues = subject.pre_publish_issues(edition, edition.revision)
      expect(issues).to be_empty
    end

    it "returns an issue if the summary is blank" do
      revision = build :revision, summary: "  "
      issues = subject.pre_publish_issues(edition, revision)
      expect(issues).to have_issue(:summary, :blank, styles: %i[form summary])
    end
  end
end
