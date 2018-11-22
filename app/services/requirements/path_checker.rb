# frozen_string_literal: true

module Requirements
  class PathChecker
    CACHE_OPTIONS = { expires_in: 5.minutes, race_condition_ttl: 10.seconds }.freeze

    attr_reader :document

    def initialize(document)
      @document = document
    end

    def pre_preview_issues(rescue_api_errors: true)
      issues = []

      begin
        if document.document_type_schema.check_path_conflict && base_path_conflict?
          issues << Issue.new(:base_path, :conflict)
        end
      rescue GdsApi::BaseError => e
        Rails.logger.error(e) if rescue_api_errors
        raise unless rescue_api_errors
      end

      CheckerIssues.new(issues)
    end

  private

    def base_path_conflict?
      cache_id = "lookup_content_id.#{document.base_path}"

      base_path_owner = Rails.cache.fetch(cache_id, CACHE_OPTIONS) do
        GdsApi.publishing_api_v2.lookup_content_id(
          base_path: document.base_path,
          with_drafts: true,
        )
      end

      base_path_owner && base_path_owner != document.content_id
    end
  end
end
