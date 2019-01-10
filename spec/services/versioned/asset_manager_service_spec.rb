# frozen_string_literal: true

RSpec.describe Versioned::AssetManagerService do
  describe "#upload" do
    it "uploads a byte stream to Asset Manager and returns the asset URL" do
      asset = double(:asset,
                     content_type: "type",
                     filename: "foo/bar.jpg",
                     bytes: "bytes")
      asset_manager_receives_an_asset("response_asset_manager_file_url")

      response = Versioned::AssetManagerService.new.upload(asset, "auth_bypass_id")
      expect(response).to eq("response_asset_manager_file_url")
    end

    it "uploads like a Rack::Multipart::UploadedFile to preserve metadata" do
      asset = double(:asset,
                     content_type: "type",
                     filename: "foo/bar.jpg",
                     bytes: "bytes")
      asset_manager_receives_an_asset("response_asset_manager_file_url")

      Versioned::AssetManagerService.new.upload(asset, "auth_bypass_id")

      request = a_request(:post, /.*/).with do |req|
        expect(req.body).to include("filename=\"bar.jpg")
        expect(req.body).to include("Content-Type: type")
        expect(req.body).to include("bytes")
        expect(req.body).to include("auth_bypass_ids")
      end

      expect(request).to have_been_requested
    end
  end

  describe "#publish" do
    it "updates an asset's draft status to false in Asset Manager" do
      asset = double(:asset, asset_manager_id: "id")

      body = { "draft" => false }
      asset_manager_update_asset(asset.asset_manager_id, body)

      response = Versioned::AssetManagerService.new.publish(asset)
      expect(response["draft"]).to be false
    end
  end

  describe "#draft" do
    it "updates an asset's draft status to true in Asset Manager" do
      asset = double(:asset, asset_manager_id: "id")

      body = { "draft" => true }
      asset_manager_update_asset(asset.asset_manager_id, body)

      response = Versioned::AssetManagerService.new.draft(asset, "auth_bypass_id")
      expect(response["draft"]).to be true
    end
  end
  describe "#redirect" do
    it "sets a redirect_url on an asset" do
      asset = double(:asset, asset_manager_id: "id")
      url = "https://example.com/asset-path.jpg"

      body = { "redirect_url" => url }
      asset_manager_update_asset(asset.asset_manager_id, body)

      response = Versioned::AssetManagerService.new.redirect(asset, to: url)
      expect(response["redirect_url"]).to eq(url)
    end
  end

  describe "#delete" do
    it "deletes an asset from Asset Manager" do
      asset = double(:asset, asset_manager_id: "id")

      asset_manager_delete_asset(asset.asset_manager_id)

      response = Versioned::AssetManagerService.new.delete(asset)
      expect(response.code).to eq 200
    end
  end
end
