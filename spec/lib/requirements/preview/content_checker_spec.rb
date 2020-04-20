RSpec.describe Requirements::Preview::ContentChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      edition = build :edition
      issues = described_class.call(edition)
      expect(issues).to be_empty
    end

    it "delegates to return issues with content fields" do
      issues = Requirements::CheckerIssues.new(%w(issue))
      body_field = instance_double(DocumentType::BodyField, pre_preview_issues: issues)
      document_type = build :document_type, contents: [body_field]
      edition = build :edition, document_type: document_type
      issues = described_class.call(edition)
      expect(issues).to eq issues
    end
  end
end
