# frozen_string_literal: true

RSpec.describe PreviewAssetService do
  describe "#upload_assets" do
    it "uploads the image assets" do
      image_revision = create(:image_revision)
      edition = create(:edition, image_revisions: [image_revision])
      expect_any_instance_of(PreviewAssetService).to receive(:upload_asset).at_least(:once)
      PreviewAssetService.new(edition).upload_assets
    end

    it "uploads the file attachment assets" do
      file_attachment_revision = create(:file_attachment_revision)
      edition = create(:edition, file_attachment_revisions: [file_attachment_revision])
      expect_any_instance_of(PreviewAssetService).to receive(:upload_asset).at_least(:once)
      PreviewAssetService.new(edition).upload_assets
    end
  end

  describe "#upload_asset" do
    let(:edition) { create :edition }

    let(:asset) do
      double(absent?: true,
             asset_manager_id: "id",
             update!: false,
             bytes: "0x123",
             filename: "abc.png",
             content_type: "image/png")
    end

    context "when the asset is not on Asset Manager" do
      it "uploads the asset" do
        request = stub_asset_manager_receives_an_asset
        expect(asset).to receive(:update!).with a_hash_including(state: :draft)
        PreviewAssetService.new(edition).upload_asset(asset)
        expect(request).to have_been_requested.at_least_once
      end
    end

    context "when the asset is on Asset Manager" do
      it "doesn't upload the asset" do
        allow(asset).to receive(:absent?) { false }
        request = stub_asset_manager_receives_an_asset
        PreviewAssetService.new(edition).upload_asset(asset)
        expect(asset).to_not have_received(:update!)
        expect(request).to_not have_been_requested
      end
    end
  end

  describe "#can_preview_asset?" do
    let(:edition) { create :edition }

    let(:asset) do
      double(absent?: true,
             asset_manager_id: "id",
             update!: false,
             bytes: "0x123",
             filename: "abc.png",
             content_type: "image/png")
    end

    it "returns true when the asset is uploaded" do
      stub_asset_manager_has_an_asset("id", "state": "uploaded")
      result = PreviewAssetService.new(edition).can_preview_asset?(asset)
      expect(result).to be_truthy
    end

    it "returns false when the asset is being scanned" do
      stub_asset_manager_has_an_asset("id", "state": "unscanned")
      result = PreviewAssetService.new(edition).can_preview_asset?(asset)
      expect(result).to be_falsey
    end
  end
end
