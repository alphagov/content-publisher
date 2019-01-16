# frozen_string_literal: true

module AssetManagerHelper
  ENDPOINT = GdsApi::TestHelpers::AssetManager::ASSET_MANAGER_ENDPOINT

  def stub_asset_manager_receives_assets
    stub_request(:post, "#{ENDPOINT}/assets").to_return do
      file_url = "#{ENDPOINT}/media/#{SecureRandom.uuid}/#{SecureRandom.alphanumeric(8)}"
      { body: { file_url: file_url }.to_json, status: 200 }
    end
  end
end
