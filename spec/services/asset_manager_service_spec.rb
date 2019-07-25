# frozen_string_literal: true

RSpec.describe AssetManagerService do
  describe "#delete" do
    it "deletes an asset from Asset Manager" do
      asset = double(:asset, asset_manager_id: "id")

      stub_asset_manager_delete_asset(asset.asset_manager_id)

      response = AssetManagerService.new.delete(asset)
      expect(response.code).to eq 200
    end
  end
end
