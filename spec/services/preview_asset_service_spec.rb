RSpec.describe PreviewAssetService do
  describe ".call" do
    let(:edition) { create :edition }

    let(:asset) do
      double(asset_manager_id: "id", # rubocop:disable RSpec/VerifiedDoubles
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
        allow(asset).to receive(:draft?).and_return(false)
        allow(asset).to receive(:absent?).and_return(true)
        file = PreviewAssetService::UploadedFile.new(asset)

        payload = instance_double(PreviewAssetService::Payload)
        allow(payload).to receive(:for_upload).and_return(file:, foo: "bar")
        allow(PreviewAssetService::Payload).to receive(:new).and_return(payload)
      end

      it "uploads and updates the asset" do
        request = stub_asset_manager_receives_an_asset(file_url)

        expect(asset).to receive(:update!)
          .with a_hash_including(state: :draft, file_url:)

        described_class.call(edition, asset)
        expect(request).to have_been_requested.at_least_once
      end

      it "uploads like a Rack::Multipart::UploadedFile" do
        stub_asset_manager_receives_an_asset

        request = a_request(:post, /.*/).with do |req|
          expect(req.body).to include("filename=\"bar.jpg")
          expect(req.body).to include("Content-Type: type")
          expect(req.body).to include("foo")
        end

        described_class.call(edition, asset)
        expect(request).to have_been_requested
      end
    end

    context "when a draft asset is on Asset Manager" do
      before do
        allow(asset).to receive(:draft?).and_return(true)
        allow(asset).to receive(:absent?).and_return(false)

        payload = instance_double(PreviewAssetService::Payload)
        allow(payload).to receive(:for_update).and_return(foo: "bar")
        allow(PreviewAssetService::Payload).to receive(:new).and_return(payload)
      end

      it "updates the asset" do
        request = stub_asset_manager_update_asset("id")
        described_class.call(edition, asset)
        expect(request).to have_been_requested
      end

      it "updates the asset with metadata" do
        stub_asset_manager_updates_any_asset

        request = a_request(:put, /.*/).with do |req|
          expect(req.body).to include("foo")
        end

        described_class.call(edition, asset)
        expect(request).to have_been_requested
      end
    end

    context "when a live asset is on Asset Manager" do
      it "does not update the asset" do
        request = stub_asset_manager_update_asset("id")
        allow(asset).to receive(:draft?).and_return(false)
        allow(asset).to receive(:absent?).and_return(false)
        described_class.call(edition, asset)
        expect(request).not_to have_been_requested
      end
    end
  end
end
