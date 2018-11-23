# frozen_string_literal: true

module Requirements
  class PathChecker
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def pre_preview_issues
      issues = []

      begin
        if document.document_type_schema.check_path_conflict && base_path_conflict?
          issues << Issue.new(:base_path, :conflict)
        end
      rescue GdsApi::BaseError => e
        Rails.logger.error(e)
      end

      CheckerIssues.new(issues)
    end

  private

    def base_path_conflict?
      base_path_owner = GdsApi.publishing_api_v2.lookup_content_id(
        base_path: document.base_path,
        with_drafts: true,
      )

      base_path_owner && base_path_owner != document.content_id
    end
  end
end
