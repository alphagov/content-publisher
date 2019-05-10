# frozen_string_literal: true

class PreviewService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def create_preview
    PreviewAssetService.new(edition).upload_assets
    publish_draft
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

  def publish_draft
    payload = PublishingApiPayload.new(edition).payload
    GdsApi.publishing_api_v2.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  end
end
