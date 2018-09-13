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
end
