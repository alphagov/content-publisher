# frozen_string_literal: true

require "spec_helper"

RSpec.describe AssetManagerService do
  describe "#upload_bytes" do
    it "uploads a byte stream to Asset Manager and returns the asset URL" do
      image = create(:image)
      asset_manager_receives_an_asset("response_asset_manager_file_url")

      response = AssetManagerService.new.upload_bytes(image, image.cropped_bytes)
      expect(response).to eq("response_asset_manager_file_url")
    end
  end

  describe "#publish" do
    it "updates an asset's draft status to false in Asset Manager" do
      image = create(:image, :in_asset_manager)

      body = { "draft" => false }
      asset_manager_update_asset(image.asset_manager_id, body)

      response = AssetManagerService.new.publish(image)
      expect(response["draft"]).to be false
    end
  end

  describe "#delete" do
    it "deletes an asset from Asset Manager" do
      image = create(:image, :in_asset_manager)

      asset_manager_delete_asset(image.asset_manager_id)

      response = AssetManagerService.new.delete(image)
      expect(response.code).to eq 200
    end
  end
end
