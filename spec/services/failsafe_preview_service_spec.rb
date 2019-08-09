# frozen_string_literal: true

RSpec.describe FailsafePreviewService do
  before do
    allow(PreviewService).to receive(:call)
    allow(AssetCleanupJob).to receive(:perform_later)
  end

  describe ".call" do
    it "delegates to the PreviewService" do
      edition = create(:edition)
      expect(PreviewService).to receive(:call)
      FailsafePreviewService.call(edition)
    end

    context "when an external service is down" do
      it "sets revision_synced to false on the edition" do
        allow(PreviewService).to receive(:call).and_raise(GdsApi::BaseError)
        edition = create(:edition, revision_synced: true)
        FailsafePreviewService.call(edition)
        expect(edition.revision_synced).to be(false)
      end
    end

    context "when there are pre-preview issues" do
      let(:edition) { create(:edition, title: "", revision_synced: true) }

      it "sets revision_synced to false on the edition" do
        FailsafePreviewService.call(edition)
        expect(edition.revision_synced).to be(false)
      end

      it "doesn't send to the Publishing API" do
        request = stub_publishing_api_put_content(edition.content_id, {})
        FailsafePreviewService.call(edition)
        expect(request).not_to have_been_requested
      end
    end
  end
end
