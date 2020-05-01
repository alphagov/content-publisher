class FailsafeDraftPreviewService < ApplicationService
  def initialize(edition)
    @edition = edition
  end

  def call
    if has_issues?
      edition.update!(revision_synced: false)
    else
      PreviewDraftEditionService.call(edition)
    end
  rescue GdsApi::BaseError => e
    edition.update!(revision_synced: false)
    GovukError.notify(e)
  end

private

  attr_reader :edition

  def has_issues?
    Requirements::Preview::EditionChecker.call(edition).any?
  end
end
