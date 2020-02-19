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

  describe "#pre_publish_issues" do
    it "delegates to #pre_update_issues" do
      edition = build :edition, tags: { tag: %w[id1 id2] }
      checker = described_class.new(edition)
      expect(checker).to receive(:pre_update_issues).with(tag: %w[id1 id2])
      checker.pre_publish_issues
    end
  end
end
