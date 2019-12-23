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
          if whitehall_asset.file_attachment_revision.present?
            delete_variants(whitehall_asset)
          end
        else
          GdsApi.asset_manager.delete_asset(whitehall_asset.asset_manager_id)
          delete_variants(whitehall_asset)
          # @TODO - do we want to delete the content publisher bits too?
        end

        whitehall_asset.update!(state: "processed")
      end
    end

  private

    def asset_manager_id(file_url)
      url_array = file_url.to_s.split("/")
      # https://github.com/alphagov/asset-manager#create-an-asset
      url_array[url_array.length - 2]
    end

    def delete_variants(whitehall_asset)
      whitehall_asset.variants.each do |_variant, url|
        GdsApi.asset_manager.delete_asset(asset_manager_id(url))
      end
    end
  end
end
