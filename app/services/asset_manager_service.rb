# frozen_string_literal: true

require "gds_api/asset_manager"

class AssetManagerService
  def upload_bytes(asset, content)
    file = AssetManagerFile.from_bytes(asset, content)
    upload = asset_manager.create_asset(file: file, draft: true)
    upload["file_url"]
  end

  def publish(asset)
    asset_manager.update_asset(asset.asset_manager_id, file: asset, draft: false)
  end

  def delete(asset)
    asset_manager.delete_asset(asset.asset_manager_id)
  end

private

  def asset_manager
    @asset_manager ||= GdsApi::AssetManager.new(
      Plek.new.find("asset-manager"),
      bearer_token: ENV.fetch("ASSET_MANAGER_BEARER_TOKEN", "example"),
    )
  end

  # Used as a stand-in for a File / Rack::Multipart::UploadedFile object when
  # passed to GdsApi::AssetManager#create_asset. The interface is required for
  # uploading a file using the restclient we used in the backend.
  #
  # https://github.com/rest-client/rest-client/blob/master/lib/restclient/payload.rb#L181-L194
  #
  # This is done by delegating to 'io' which should implement the IO interface
  # (e.g. StringIO) and adds methods to return filename, content_type and path.
  class AssetManagerFile < SimpleDelegator
    attr_reader :asset

    def initialize(asset, io)
      super(io)
      @asset = asset
    end

    def self.from_bytes(asset, content)
      new(asset, StringIO.new(content))
    end

    def asset_manager_id
      asset.asset_manager_id
    end

    def path
      asset.filename
    end
  end
end
