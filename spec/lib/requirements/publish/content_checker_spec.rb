RSpec.describe Requirements::Publish::ContentChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      edition = build :edition, :publishable
      issues = described_class.call(edition)
      expect(issues).to be_empty
    end

    it "delegates to return issues with content fields" do
      issues = Requirements::CheckerIssues.new(%w(issue))
      body_field = instance_double(DocumentType::BodyField, publish_issues: issues)
      document_type = build :document_type, contents: [body_field]
      edition = build :edition, document_type: document_type
      issues = described_class.call(edition)
      expect(issues).to eq issues
    end

    it "returns an issue if a major change note is blank" do
      document = build :document, :with_live_edition
      edition = build :edition, update_type: "major", change_note: nil, document: document
      issues = described_class.call(edition)
      expect(issues).to have_issue(:change_note, :blank, styles: %i[form summary])
    end
  end
end
