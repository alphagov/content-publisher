RSpec.describe Requirements::Preview::ContentChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      edition = build :edition
      issues = described_class.call(edition)
      expect(issues).to be_empty
    end

    it "delegates to return issues with content fields" do
      expected_issues = Requirements::CheckerIssues.new(%w[issue])
      body_field = instance_double(DocumentType::BodyField, preview_issues: expected_issues)
      document_type = build :document_type, contents: [body_field]
      edition = build(:edition, document_type:)
      actual_issues = described_class.call(edition)
      expect(actual_issues.issues).to eq expected_issues.issues
    end
  end
end
