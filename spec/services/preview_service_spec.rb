# frozen_string_literal: true

RSpec.describe PreviewService do
  let(:draft_asset_cleanup_service) do
    instance_double("DraftAssetCleanupService", call: nil)
  end

  before do
    stub_any_publishing_api_put_content
    stub_any_asset_manager_call
    allow(DraftAssetCleanupService).to receive(:new) { draft_asset_cleanup_service }
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

    context "when there are assets that aren't on Asset Manager" do
      it "uploads the assets to Asset Manager" do
        image_revision = create(:image_revision)
        file_attachment_revision = create(:file_attachment_revision)
        edition = create(:edition,
                         image_revisions: [image_revision],
                         file_attachment_revisions: [file_attachment_revision])

        request = stub_asset_manager_receives_an_asset
        PreviewService.new(edition).create_preview

        expect(request).to have_been_requested.at_least_once
        asset_states = image_revision.assets.map(&:state) + file_attachment_revision.assets.map(&:state)
        expect(asset_states.uniq).to match(%w[draft])
      end
    end

    context "when there are assets that are on Asset Manager" do
      let(:image_revision_draft) do
        create(:image_revision, :on_asset_manager, state: :draft)
      end

      let(:image_revision_live) do
        create(:image_revision, :on_asset_manager, state: :live)
      end

      let(:file_attachment_revision_draft) do
        create(:file_attachment_revision, :on_asset_manager, state: :draft)
      end

      let(:file_attachment_revision_live) do
        create(:file_attachment_revision, :on_asset_manager, state: :live)
      end

      let(:edition) do
        create(:edition,
               image_revisions: [image_revision_draft, image_revision_live],
               file_attachment_revisions: [file_attachment_revision_draft, file_attachment_revision_live])
      end

      it "doesn't change the state of assets on asset manager" do
        PreviewService.new(edition).create_preview

        draft_asset_states = image_revision_draft.assets.map(&:state) +
          file_attachment_revision_draft.assets.map(&:state)
        expect(draft_asset_states.uniq).to match(%w[draft])

        live_asset_states = image_revision_live.assets.map(&:state) +
          file_attachment_revision_live.assets.map(&:state)
        expect(live_asset_states.uniq).to match(%w[live])
      end

      it "doesn't upload assets to asset manager" do
        request = stub_asset_manager_receives_an_asset

        PreviewService.new(edition).create_preview

        expect(request).not_to have_been_requested
      end
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

    context "when there are images and Asset Manager is down" do
      it "sets revision_synced to false on the edition" do
        stub_asset_manager_isnt_available
        image_revision = create(:image_revision)
        edition = create(:edition, image_revisions: [image_revision], revision_synced: true)

        expect { PreviewService.new(edition).create_preview }
          .to raise_error(GdsApi::BaseError)
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
