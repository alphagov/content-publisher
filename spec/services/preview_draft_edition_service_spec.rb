# frozen_string_literal: true

RSpec.describe PreviewDraftEditionService do
  before do
    stub_any_publishing_api_put_content
    allow(PreviewAssetService).to receive(:call)
  end

  describe ".call" do
    it "updates the Publishing API" do
      edition = create(:edition)
      request = stub_publishing_api_put_content(edition.content_id, {})
      PreviewDraftEditionService.call(edition)
      expect(request).to have_been_requested
    end

    it "marks the edition as 'revision_synced'" do
      edition = create(:edition, revision_synced: false)
      PreviewDraftEditionService.call(edition)
      expect(edition.reload.revision_synced).to be(true)
    end

    it "uploads any image assets" do
      image_revision = create(:image_revision)
      edition = create(:edition, image_revisions: [image_revision])
      expect(PreviewAssetService).to receive(:call).at_least(:once)
      PreviewDraftEditionService.call(edition)
    end

    it "uploads any file attachment assets" do
      file_attachment_revision = create(:file_attachment_revision)
      edition = create(:edition, file_attachment_revisions: [file_attachment_revision])
      expect(PreviewAssetService).to receive(:call).at_least(:once)
      PreviewDraftEditionService.call(edition)
    end

    it "sets an update type of republish" do
      edition = create(:edition)

      expect(PreviewDraftEditionService::Payload)
        .to receive(:new)
        .with(edition, republish: true)
        .and_call_original

      PreviewDraftEditionService.call(edition, republish: true)
    end

    context "when Publishing API is down" do
      before do
        stub_publishing_api_isnt_available
      end

      it "sets revision_synced to false on the edition" do
        edition = create(:edition, revision_synced: true)
        expect { PreviewDraftEditionService.call(edition) }.to raise_error(GdsApi::BaseError)
        expect(edition.revision_synced).to be(false)
      end
    end

    context "when the asset upload fails" do
      before do
        allow(PreviewAssetService).to receive(:call).and_raise(GdsApi::BaseError)
      end

      it "sets revision_synced to false on the edition" do
        image_revision = create(:image_revision)
        edition = create(:edition, image_revisions: [image_revision], revision_synced: true)
        expect { PreviewDraftEditionService.call(edition) }.to raise_error(GdsApi::BaseError)
        expect(edition.revision_synced).to be(false)
      end
    end
  end
end
