# frozen_string_literal: true

RSpec.describe PreviewService do
  let(:draft_asset_cleanup_service) do
    instance_double("DraftAssetCleanupService", call: nil)
  end

  let(:preview_asset_service) do
    instance_double("PreviewAssetService", upload_assets: nil)
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
      expect(preview_asset_service).to receive(:upload_assets)
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
        allow(preview_asset_service).to receive(:upload_assets).and_raise(GdsApi::BaseError)
        edition = create(:edition, revision_synced: true)
        expect { PreviewService.new(edition).create_preview }.to raise_error(GdsApi::BaseError)
        expect(edition.revision_synced).to be(false)
      end
    end
  end

  describe "#try_create_preview" do
    it "delegates to create_preview" do
      edition = create(:edition)
      service = PreviewService.new(edition)
      expect(service).to receive(:create_preview)
      service.try_create_preview
    end

    context "when an external service is down" do
      it "sets revision_synced to false on the edition" do
        stub_publishing_api_isnt_available
        edition = create(:edition, revision_synced: true)
        PreviewService.new(edition).try_create_preview
        expect(edition.revision_synced).to be(false)
      end
    end

    context "when there are pre-preview issues" do
      let(:edition) { create(:edition, title: "", revision_synced: true) }

      it "sets revision_synced to false on the edition" do
        PreviewService.new(edition).try_create_preview

        expect(edition.revision_synced).to be(false)
      end

      it "doesn't send to the Publishing API" do
        request = stub_publishing_api_put_content(edition.content_id, {})

        PreviewService.new(edition).try_create_preview

        expect(request).not_to have_been_requested
      end

      it "delegates cleaning up draft assets" do
        expect(draft_asset_cleanup_service).to receive(:call).with(edition)
        PreviewService.new(edition).try_create_preview
      end
    end
  end
end
