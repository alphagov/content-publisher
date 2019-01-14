# frozen_string_literal: true

class PreviewService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def create_preview
    upload_assets(edition)
    publish_draft(edition)
  end

  def try_create_preview
    if has_issues?
      edition.update!(revision_synced: false)
    else
      begin
        upload_assets(edition)
        publish_draft(edition)
      rescue GdsApi::BaseError => e
        GovukError.notify(e)
      end
    end
  end

private

  def has_issues?
    Requirements::EditionChecker.new(edition).pre_preview_issues.any?
  end

  def publish_draft(edition)
    payload = PublishingApiPayload.new(edition).payload
    GdsApi.publishing_api_v2.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

  def upload_assets(edition)
    edition.image_revisions.each do |image_revision|
      image_revision.ensure_assets

      image_revision.assets.each { |asset| upload_image(edition, asset) }
    end
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

  def upload_image(edition, image_asset)
    return unless image_asset.absent?

    auth_bypass_id = EditionUrl.new(edition).auth_bypass_id
    file_url = AssetManagerService.new.upload(image_asset, auth_bypass_id)
    image_asset.update!(file_url: file_url, state: :draft)
  end
end
