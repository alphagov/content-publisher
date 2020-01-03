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
      whitehall_import.migratable_assets.each do |whitehall_asset|
        begin
          migrate_asset(whitehall_asset)
        rescue StandardError => e
          whitehall_asset.update!(state: "migration_failed", error_message: e.inspect)
        end
      end
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
        whitehall_asset.whitehall_asset_id,
        redirect_url: whitehall_asset.content_publisher_asset.file_url,
      )
      whitehall_asset.update!(state: "redirected")
    end

    def remove_asset(whitehall_asset)
      GdsApi.asset_manager.delete_asset(whitehall_asset.whitehall_asset_id)
      whitehall_asset.update!(state: "removed")
    end
  end
end
