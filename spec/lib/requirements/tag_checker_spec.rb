RSpec.describe Requirements::TagChecker do
  describe "#pre_update_issues" do
    it "returns no issues when there are none" do
      edition = build(:edition)
      issues = described_class.new(edition).pre_update_issues({})
      expect(issues.items).to be_empty
    end

    it "delegates to return issues with tag fields" do
      tag = DocumentType::PrimaryPublishingOrganisationField.new
      document_type = build :document_type, tags: [tag]
      edition = build :edition, document_type: document_type

      params = { primary_publishing_organisation: SecureRandom.uuid }
      expect(tag).to receive(:pre_update_issues).with(edition, params).and_call_original
      described_class.new(edition).pre_update_issues(params)
    end
  end

  describe "#pre_preview_issues" do
    it "delegates to return issues with tag fields" do
      tag = DocumentType::PrimaryPublishingOrganisationField.new
      document_type = build :document_type, tags: [tag]
      edition = build :edition, document_type: document_type

      expect(tag).to receive(:pre_preview_issues).with(edition).and_call_original
      described_class.new(edition).pre_preview_issues
    end
  end

  describe "#pre_publish_issues" do
    it "delegates to return issues with tag fields" do
      tag = DocumentType::PrimaryPublishingOrganisationField.new
      document_type = build :document_type, tags: [tag]
      edition = build :edition, document_type: document_type

      expect(tag).to receive(:pre_publish_issues).with(edition).and_call_original
      described_class.new(edition).pre_publish_issues
    end
  end
end
