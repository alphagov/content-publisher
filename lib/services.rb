# frozen_string_literal: true

require "gds_api/publishing_api_v2"

module Services
  def self.publishing_api
    @publishing_api ||= begin
      GdsApi::PublishingApiV2.new(
        Plek.new.find("publishing-api"),
        disable_cache: true,
        bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
      )
    end
  end

  def self.asset_manager
    @asset_manager ||= GdsApi::AssetManager.new(
      Plek.new.find("asset-manager"),
      bearer_token: ENV.fetch("ASSET_MANAGER_BEARER_TOKEN", "example"),
    )
  end
end
