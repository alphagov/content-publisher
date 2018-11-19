# frozen_string_literal: true

require "spec_helper"

RSpec.describe AssetManagerService do
  describe "#upload_bytes" do
    it "uploads a byte stream to Asset Manager and returns the asset URL" do
      asset = double(:asset,
                     content_type: "type",
                     filename: "foo/bar.jpg",
                     document: build(:document))
      asset_manager_receives_an_asset("response_asset_manager_file_url")

      response = AssetManagerService.new.upload_bytes(asset, "bytes")
      expect(response).to eq("response_asset_manager_file_url")
    end

    it "uploads like a Rack::Multipart::UploadedFile to preserve metadata" do
      asset = double(:asset,
                     content_type: "type",
                     filename: "foo/bar.jpg",
                     document: build(:document))
      asset_manager_receives_an_asset("response_asset_manager_file_url")

      AssetManagerService.new.upload_bytes(asset, "bytes")

      expect(a_request(:post, /.*/).with { |req|
        expect(req.body).to include("filename=\"bar.jpg")
        expect(req.body).to include("Content-Type: #{asset.content_type}")
        expect(req.body).to include("bytes")
        expect(req.body).to include("auth_bypass_ids")
      }).to have_been_requested
    end
  end

  describe "#publish" do
    it "updates an asset's draft status to false in Asset Manager" do
      asset = double(:asset, asset_manager_id: "id")

      body = { "draft" => false }
      asset_manager_update_asset(asset.asset_manager_id, body)

      response = AssetManagerService.new.publish(asset)
      expect(response["draft"]).to be false
    end
  end

  describe "#delete" do
    it "deletes an asset from Asset Manager" do
      asset = double(:asset, asset_manager_id: "id")

      asset_manager_delete_asset(asset.asset_manager_id)

      response = AssetManagerService.new.delete(asset)
      expect(response.code).to eq 200
    end
  end
end
