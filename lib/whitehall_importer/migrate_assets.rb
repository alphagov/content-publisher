# frozen_string_literal: true

module WhitehallImporter
  class MigrateAssets
    attr_reader :whitehall_import

    def self.call(*args)
      new(*args).call
    end

    def initialize(whitehall_import)
      @whitehall_import = whitehall_import
    end

    def call
      whitehall_import.assets.each do |whitehall_asset|
        whitehall_asset.update!(state: "processing")
        if whitehall_asset.main_asset.state == "live"
          GdsApi.asset_manager.update_asset(
            whitehall_asset.asset_manager_id,
            redirect_url: whitehall_asset.main_asset.file_url,
          )
        end
        whitehall_asset.update!(state: "processed")
      end
    end
  end
end
