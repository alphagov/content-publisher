# frozen_string_literal: true

RSpec.describe FailsafePreviewService do
  let(:preview_service) do
    instance_double(PreviewService, create_preview: nil)
  end

  before do
    allow(PreviewService).to receive(:new) { preview_service }
    allow_any_instance_of(DraftAssetCleanupService).to receive(:call)
  end

  describe "#create_preview" do
    it "delegates to the PreviewService" do
      edition = create(:edition)
      service = FailsafePreviewService.new(edition)
      expect(preview_service).to receive(:create_preview)
      service.create_preview
    end

    context "when an external service is down" do
      it "sets revision_synced to false on the edition" do
        allow(preview_service).to receive(:create_preview).and_raise(GdsApi::BaseError)
        edition = create(:edition, revision_synced: true)
        FailsafePreviewService.new(edition).create_preview
        expect(edition.revision_synced).to be(false)
      end
    end

    context "when there are pre-preview issues" do
      let(:edition) { create(:edition, title: "", revision_synced: true) }

      it "sets revision_synced to false on the edition" do
        FailsafePreviewService.new(edition).create_preview
        expect(edition.revision_synced).to be(false)
      end

      it "doesn't send to the Publishing API" do
        request = stub_publishing_api_put_content(edition.content_id, {})
        FailsafePreviewService.new(edition).create_preview
        expect(request).not_to have_been_requested
      end

      it "delegates cleaning up draft assets" do
        expect_any_instance_of(DraftAssetCleanupService).to receive(:call)
        FailsafePreviewService.new(edition).create_preview
      end
    end
  end
end
