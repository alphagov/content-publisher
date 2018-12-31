# frozen_string_literal: true

module Versioned
  class PreviewService
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def create_preview
      publish_draft(edition)
    end

    def try_create_preview
      if has_issues?
        edition.status.publishing_api_sync_cant_sync!
      else
        try_publish_draft(edition)
      end
    end

  private

    def has_issues?
      Versioned::Requirements::EditionChecker.new(edition).pre_preview_issues.any?
    end

    def try_publish_draft(edition)
      publish_draft(edition)
    rescue GdsApi::BaseError => e
      GovukError.notify(e)
    end

    def publish_draft(document)
      payload = PublishingApiPayload.new(document).payload
      GdsApi.publishing_api_v2.put_content(document.content_id, payload)
      edition.status.publishing_api_sync_complete!
    rescue GdsApi::BaseError
      edition.status.publishing_api_sync_failure!
      raise
    end
  end
end
