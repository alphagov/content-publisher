# frozen_string_literal: true

module AssetManagerHelper
  ENDPOINT = GdsApi::TestHelpers::AssetManager::ASSET_MANAGER_ENDPOINT

  def stub_asset_manager_receives_assets(filename = nil)
    stub_request(:post, "#{ENDPOINT}/assets").to_return do
      filename ||= SecureRandom.alphanumeric(8)
      file_url = "#{ENDPOINT}/media/#{SecureRandom.uuid}/#{filename}"
      { body: { file_url: file_url }.to_json, status: 200 }
    end
  end

  def stub_asset_manager_updates_assets
    stub_request(:put, %r{\A#{ENDPOINT}/assets}).to_return(status: 200)
  end

  def stub_asset_manager_deletes_assets
    stub_request(:delete, %r{\A#{ENDPOINT}/assets}).to_return(status: 200)
  end

  def stub_asset_manager_down
    stub_request(:any, %r{\A#{ENDPOINT}}).to_return(status: 503)
  end

  def stub_any_asset_manager_call
    stub_request(:any, %r{\A#{ENDPOINT}}).to_return(status: 200)
  end
end
