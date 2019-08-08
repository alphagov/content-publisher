# frozen_string_literal: true

RSpec.describe PreviewService do
  let(:draft_asset_cleanup_service) do
    instance_double(DraftAssetCleanupService, call: nil)
  end

  let(:preview_asset_service) do
    instance_double(PreviewAssetService, put: nil)
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

    it "uploads any image assets" do
      image_revision = create(:image_revision)
      edition = create(:edition, image_revisions: [image_revision])
      expect(preview_asset_service).to receive(:put).at_least(:once)
      PreviewService.new(edition).create_preview
    end

    it "uploads any file attachment assets" do
      file_attachment_revision = create(:file_attachment_revision)
      edition = create(:edition, file_attachment_revisions: [file_attachment_revision])
      expect(preview_asset_service).to receive(:put).at_least(:once)
      PreviewService.new(edition).create_preview
    end

    context "when Publishing API is down" do
      before do
        stub_publishing_api_isnt_available
      end

      it "sets revision_synced to false on the edition" do
        edition = create(:edition, revision_synced: true)
        expect { PreviewService.new(edition).create_preview }.to raise_error(GdsApi::BaseError)
        expect(edition.revision_synced).to be(false)
      end
    end

    context "when the asset upload fails" do
      before do
        allow(preview_asset_service).to receive(:put).and_raise(GdsApi::BaseError)
      end

      it "sets revision_synced to false on the edition" do
        image_revision = create(:image_revision)
        edition = create(:edition, image_revisions: [image_revision], revision_synced: true)
        expect { PreviewService.new(edition).create_preview }.to raise_error(GdsApi::BaseError)
        expect(edition.revision_synced).to be(false)
      end
    end
  end
end
