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
  end
end
