# frozen_string_literal: true

require "spec_helper"

RSpec.describe AssetManagerService do
  describe "#upload" do
    it "returns a valid response if upload to Asset Manager is successful" do
      image = create(:image)
      asset_manager_file_url = "http://asset-manager.test.gov.uk/#{image.filename}"
      asset_manager_receives_an_asset(asset_manager_file_url)

      response = AssetManagerService.new(image.crop_variant).upload
      expect(response["file_url"]).to eq(asset_manager_file_url)
      expect(response.code).to eq(200)
    end
  end
end
