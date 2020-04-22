RSpec.describe Requirements::Form::TagsChecker do
  describe ".call" do
    it "returns no issues when there are none" do
      edition = build(:edition)
      issues = described_class.call(edition, {})
      expect(issues.items).to be_empty
    end

    it "delegates to return issues with tag fields" do
      tag = DocumentType::PrimaryPublishingOrganisationField.new
      document_type = build :document_type, tags: [tag]
      edition = build :edition, document_type: document_type

      params = { primary_publishing_organisation: SecureRandom.uuid }
      expect(tag).to receive(:form_issues).with(edition, params).and_call_original
      described_class.call(edition, params)
    end
  end
end
