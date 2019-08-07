# frozen_string_literal: true

RSpec.describe PreviewService do
  let(:draft_asset_cleanup_service) do
    instance_double(DraftAssetCleanupService, call: nil)
  end

  let(:preview_asset_service) do
    instance_double(PreviewAssetService, put_all: nil)
  end

  before do
    stub_any_publishing_api_put_content
    allow(DraftAssetCleanupService).to receive(:new) { draft_asset_cleanup_service }
    allow(PreviewAssetService).to receive(:new) { preview_asset_service }
  end

  describe "#create_preview" do
    it "updates the Publishing API" do
      edition = create(:edition)
      request = stub_publishing_api_put_content(edition.content_id, {})
      PreviewService.new(edition).create_preview
      expect(request).to have_been_requested
    end

    it "marks the edition as 'revision_synced'" do
      edition = create(:edition, revision_synced: false)
      PreviewService.new(edition).create_preview
      expect(edition.reload.revision_synced).to be(true)
    end

    it "delegates cleaning up draft assets" do
      edition = create(:edition)
      expect(draft_asset_cleanup_service).to receive(:call).with(edition)
      PreviewService.new(edition).create_preview
    end

    it "delegates previewing assets" do
      edition = create(:edition)
      expect(preview_asset_service).to receive(:put_all)
      PreviewService.new(edition).create_preview
    end

    context "when Publishing API is down" do
      it "sets revision_synced to false on the edition" do
        stub_publishing_api_isnt_available
        edition = create(:edition, revision_synced: true)

        expect { PreviewService.new(edition).create_preview }
          .to raise_error(GdsApi::BaseError)
        expect(edition.revision_synced).to be(false)
      end
    end

    context "when the asset upload fails" do
      it "sets revision_synced to false on the edition" do
        allow(preview_asset_service).to receive(:put_all).and_raise(GdsApi::BaseError)
        edition = create(:edition, revision_synced: true)
        expect { PreviewService.new(edition).create_preview }.to raise_error(GdsApi::BaseError)
        expect(edition.revision_synced).to be(false)
      end
    end
  end
end
