# frozen_string_literal: true

class FailsafePreviewService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def create_preview
    if has_issues?
      DraftAssetCleanupService.new.call(edition)
      edition.update!(revision_synced: false)
    else
      PreviewService.new(edition).create_preview
    end
  rescue GdsApi::BaseError => e
    edition.update!(revision_synced: false)
    GovukError.notify(e)
  end

private

  def has_issues?
    Requirements::EditionChecker.new(edition).pre_preview_issues.any?
  end
end
