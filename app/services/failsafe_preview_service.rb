# frozen_string_literal: true

class FailsafePreviewService < ApplicationService
  def initialize(edition)
    @edition = edition
  end

  def call
    if has_issues?
      DraftAssetCleanupService.call(edition)
      edition.update!(revision_synced: false)
    else
      PreviewService.call(edition)
    end
  rescue GdsApi::BaseError => e
    edition.update!(revision_synced: false)
    GovukError.notify(e)
  end

private

  attr_reader :edition

  def has_issues?
    Requirements::EditionChecker.new(edition).pre_preview_issues.any?
  end
end
