module WhitehallImporter
  class MigrateAssets
    attr_reader :whitehall_import

    def self.call(...)
      new(...).call
    end

    def initialize(whitehall_import)
      @whitehall_import = whitehall_import
    end

    def call
      whitehall_import.migratable_assets.each do |whitehall_asset|
        migrate_asset(whitehall_asset)
      rescue StandardError => e
        whitehall_asset.update!(state: "migration_failed", error_message: e.inspect)
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

    def asset_id(_whitehall_asset)
      raise NotImplementedError, "Re-implementation is required using the new Asset Manager API"
    end
  end
end
