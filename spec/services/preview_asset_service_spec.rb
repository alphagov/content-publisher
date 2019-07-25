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
      double(asset_manager_id: "id",
             update!: false,
             content_type: "type",
             filename: "foo/bar.jpg",
             bytes: "bytes")
    end

    context "when the asset is not on Asset Manager" do
      let(:file_url) do
        "https://asset-manager/media/0053adbf-0737-4923-9d8a-8180f2c723af/0d19136c4a94f07"
      end

      before do
        allow(asset).to receive(:draft?) { false }
        allow(asset).to receive(:absent?) { true }
      end

      it "uploads the asset" do
        request = stub_asset_manager_receives_an_asset(file_url)
        allow(asset).to receive(:absent?) { true }
        allow(asset).to receive(:draft?) { false }

        expect(asset).to receive(:update!)
          .with a_hash_including(state: :draft, file_url: file_url)

        PreviewAssetService.new(edition).upload_asset(asset)
        expect(request).to have_been_requested.at_least_once
      end

      it "uploads like a Rack::Multipart::UploadedFile" do
        stub_asset_manager_receives_an_asset

        request = a_request(:post, /.*/).with do |req|
          expect(req.body).to include("filename=\"bar.jpg")
          expect(req.body).to include("Content-Type: type")
          expect(req.body).to include("bytes")
          expect(req.body).to include("auth_bypass_ids")
        end

        PreviewAssetService.new(edition).upload_asset(asset)
        expect(request).to have_been_requested
      end
    end

    context "when a draft asset is on Asset Manager" do
      it "updates the asset" do
        request = stub_asset_manager_update_asset("id")
        allow(asset).to receive(:draft?) { true }
        allow(asset).to receive(:absent?) { false }
        PreviewAssetService.new(edition).upload_asset(asset)
        expect(request).to have_been_requested
      end
    end

    context "when a live asset is on Asset Manager" do
      it "does not update the asset" do
        request = stub_asset_manager_update_asset("id")
        allow(asset).to receive(:draft?) { false }
        allow(asset).to receive(:absent?) { false }
        PreviewAssetService.new(edition).upload_asset(asset)
        expect(request).to_not have_been_requested
      end
    end
  end
end
