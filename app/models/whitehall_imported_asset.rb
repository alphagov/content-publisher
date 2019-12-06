# frozen_string_literal: true

# Represents the raw import of an asset from Whitehall Publisher and
# the import status of the asset into Content Publisher
class WhitehallImportedAsset < ApplicationRecord
  def call
    update_attributes!(state: "processing")
    if asset_exists_in_a_live_edition?
      GdsApi.asset_manager.update_asset(asset_manager_id(original_asset_url),
                                        redirect_url: asset.file_url)
      if attachment.present?
        delete_all_variants
      elsif image.present?
        variants.each do |variant|
          GdsApi.asset_manager.update_asset(
            asset_manager_id(variant),
            redirect_url: attachment.file_url,
          )
        end
      end
    else
      GdsApi.asset_manager.delete_asset(asset_manager_id(original_asset_url))
      delete_all_variants
    end
    update_attributes!(state: "processed")
  end

private

  def asset_exists_in_a_live_edition?
    # definitely doesn't exist on live if document has never been published
    return false unless whitehall_import.document.live?

    # definitely exists on live if current edition is the live one
    return true unless whitehall_import.document.current.live?

    # this bit is trickier - asset may only exist in the current (draft) edition
    # and not in the preceding (live) edition
    # @TODO - write this logic later. For now, safest thing is to assume true:
    true
  end

  # adapted from app/models/file_attachment/asset.rb.
  # not the worst thing in the world, but should rethink this.
  def asset_manager_id(file_url)
    url_array = file_url.to_s.split("/")
    # https://github.com/alphagov/asset-manager#create-an-asset
    url_array[url_array.length - 2]
  end

  def delete_all_variants
    variants.each do |variant|
      GdsApi.asset_manager.delete_asset(asset_manager_id(variant))
    end
  end

  def asset
    return attachment if attachment.present?
    return image if image.present?

    update_attributes!(state: "aborted")
    throw "No attachment or image associated with WhitehallImportedAsset!"
  end

  def attachment
    file_attachment_revision
  end

  def image
    image_revision
  end
end
