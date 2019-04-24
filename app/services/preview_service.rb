# frozen_string_literal: true

class PreviewService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def create_preview
    upload_assets(edition)
    publish_draft(edition)
    DraftAssetCleanupService.new.call(edition)
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

  def try_create_preview
    if has_issues?
      DraftAssetCleanupService.new.call(edition)
      edition.update!(revision_synced: false)
    else
      create_preview
    end
  rescue GdsApi::BaseError => e
    edition.update!(revision_synced: false)
    GovukError.notify(e)
  end

private

  def has_issues?
    Requirements::EditionChecker.new(edition).pre_preview_issues.any?
  end

  def publish_draft(edition)
    payload = PublishingApiPayload.new(edition).payload
    GdsApi.publishing_api_v2.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  end

  def upload_assets(edition)
    edition.image_revisions.each do |image_revision|
      image_revision.ensure_assets

      image_revision.assets.each { |asset| upload_asset(edition, asset) }
    end

    edition.file_attachment_revisions.each do |file_attachment_revision|
      file_attachment_revision.ensure_assets

      file_attachment_revision.assets.each { |asset| upload_asset(edition, asset) }
    end
  end

  def upload_asset(edition, asset)
    return unless asset.absent?

    auth_bypass_id = EditionUrl.new(edition).auth_bypass_id
    file_url = AssetManagerService.new.upload(asset, auth_bypass_id)
    asset.update!(file_url: file_url, state: :draft)
  end
end
