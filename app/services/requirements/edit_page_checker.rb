# frozen_string_literal: true

module Requirements
  class EditPageChecker
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def pre_preview_issues
      issues = []
      issues += PathChecker.new(document).pre_preview_issues.to_a
      issues += ContentChecker.new(document).pre_preview_issues.to_a
      CheckerIssues.new(issues)
    end

  private

    def lookup_content_id
      GdsApi.publishing_api_v2.lookup_content_id(base_path: document.base_path)
    end
  end
end
