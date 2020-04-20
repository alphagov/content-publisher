RSpec.describe Requirements::Preview::TagsChecker do
  describe ".call" do
    it "delegates to return issues with tag fields" do
      tag = DocumentType::PrimaryPublishingOrganisationField.new
      document_type = build :document_type, tags: [tag]
      edition = build :edition, document_type: document_type

      expect(tag).to receive(:pre_preview_issues).with(edition).and_call_original
      described_class.call(edition)
    end
  end
end
