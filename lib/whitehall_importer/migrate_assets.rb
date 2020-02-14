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
      whitehall_import.migratable_assets.each do |whitehall_asset|
        begin
          migrate_asset(whitehall_asset)
        rescue StandardError => e
          whitehall_asset.update!(state: "migration_failed", error_message: e.inspect)
        end
      end
      raise "Failed migrating at least one Whitehall asset" if whitehall_import.assets.migration_failed.any?
    end

  private

    def migrate_asset(whitehall_asset)
      if whitehall_asset.content_publisher_asset&.live?
        redirect_asset(whitehall_asset)
      else
        remove_asset(whitehall_asset)
      end
    end

    def redirect_asset(whitehall_asset)
      GdsApi.asset_manager.update_asset(
        asset_id(whitehall_asset),
        redirect_url: whitehall_asset.content_publisher_asset.file_url,
      )
      whitehall_asset.update!(state: "redirected")
    end

    def remove_asset(whitehall_asset)
      GdsApi.asset_manager.delete_asset(asset_id(whitehall_asset))
      whitehall_asset.update!(state: "removed")
    end

    def asset_id(whitehall_asset)
      attributes = GdsApi.asset_manager
                         .whitehall_asset(whitehall_asset.legacy_url_path)
                         .to_h
      attributes["id"].split("/").last
    end
  end
end
