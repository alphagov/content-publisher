# frozen_string_literal: true

module Requirements
  class EditPageChecker
    attr_reader :edition, :revision

    def initialize(edition, revision = nil)
      @edition = edition
      @revision = revision || edition.revision
    end

    def pre_preview_issues
      issues = []
      issues += PathChecker.new(edition, revision).pre_preview_issues.to_a
      issues += ContentChecker.new(edition, revision).pre_preview_issues.to_a
      CheckerIssues.new(issues)
    end
  end
end
