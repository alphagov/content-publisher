# frozen_string_literal: true

require "spec_helper"

RSpec.describe AssetManagerService do
  describe "#upload" do
    it "returns the asset's file URL if upload to Asset Manager is successful" do
      image = create(:image)
      asset_manager_file_url = "http://asset-manager.test.gov.uk/#{image.filename}"
      asset_manager_receives_an_asset(asset_manager_file_url)

      response = AssetManagerService.new.upload(image.crop_variant)
      expect(response).to eq(asset_manager_file_url)
    end
  end

  describe "#publish" do
    it "updates an asset's draft status to false in Asset Manager" do
      asset_id = SecureRandom.uuid
      image = create(:image)
      file_url = "https://asset-manager.test.gov.uk/media/#{asset_id}/#{image.filename}"
      image.update!(asset_manager_file_url: file_url)

      body = { "draft" => false }
      stub_request(:put, "https://asset-manager.test.gov.uk/assets/#{asset_id}")
        .to_return(body: body.to_json, status: 200)

      response = AssetManagerService.new.publish(image.cropped_file)
      expect(response["draft"]).to be false
    end
  end
end
