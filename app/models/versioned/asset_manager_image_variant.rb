# frozen_string_literal: true

module Versioned
  class AssetManagerImageVariant < ApplicationRecord
    self.table_name = "versioned_asset_manager_image_variants"

    belongs_to :image_revision,
               class_name: "Versioned::ImageRevision",
               foreign_key: :image_revision_id,
               inverse_of: :asset_manager_variants

    belongs_to :file,
               class_name: "Versioned::AssetManagerFile",
               foreign_key: :asset_manager_file_id,
               inverse_of: :image_variants

    delegate :filename, :content_type, to: :image_revision
    delegate_missing_to :file

    def self.build_with_file(variant)
      new(
        variant: variant,
        file: AssetManagerFile.new(state: :absent),
      )
    end

    def readonly?
      !new_record?
    end

    def bytes
      image_revision.bytes_for_asset_manager_variant(variant)
    end
  end
end
