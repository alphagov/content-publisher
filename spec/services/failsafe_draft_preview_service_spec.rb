RSpec.describe FailsafeDraftPreviewService do
  before do
    allow(PreviewDraftEditionService).to receive(:call)
    allow(AssetCleanupJob).to receive(:perform_later)
  end

  describe ".call" do
    it "delegates to the PreviewDraftEditionService" do
      edition = create(:edition)
      expect(PreviewDraftEditionService).to receive(:call)
      described_class.call(edition)
    end

    context "when an external service is down" do
      it "sets revision_synced to false on the edition" do
        allow(PreviewDraftEditionService).to receive(:call).and_raise(GdsApi::BaseError)
        edition = create(:edition, revision_synced: true)
        described_class.call(edition)
        expect(edition.revision_synced).to be(false)
      end
    end

    context "when there are pre-preview issues" do
      let(:edition) do
        document_type = build :document_type, contents: [DocumentType::TitleAndBasePathField.new]
        create(:edition, document_type:, title: "", revision_synced: true)
      end

      it "sets revision_synced to false on the edition" do
        described_class.call(edition)
        expect(edition.revision_synced).to be(false)
      end

      it "doesn't send to the Publishing API" do
        request = stub_publishing_api_put_content(edition.content_id, {})
        described_class.call(edition)
        expect(request).not_to have_been_requested
      end
    end
  end
end
