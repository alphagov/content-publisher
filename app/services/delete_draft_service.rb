# frozen_string_literal: true

class DeleteDraftService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def delete
    raise "Trying to delete a live document" if document.has_live_version_on_govuk
    document.images.each { |asset| delete_asset(asset) }
    discard_draft
    document.destroy!
  rescue GdsApi::BaseError
    document.update!(publication_state: "error_deleting_draft")
    raise
  end

private

  def discard_draft
    GdsApi.publishing_api_v2.discard_draft(document.content_id)
  rescue GdsApi::HTTPNotFound => e
    Rails.logger.error(e)
  end

  def delete_asset(asset)
    return unless asset.asset_manager_id
    AssetManagerService.new.delete(asset)
  rescue GdsApi::HTTPNotFound => e
    Rails.logger.error(e)
  end
end
