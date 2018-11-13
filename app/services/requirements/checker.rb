# frozen_string_literal: true

module Requirements
  class Checker
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def pre_draft_issues
      issues = []

      document.images.each do |image|
        issues += ImageChecker.new(image).pre_draft_issues.to_a
      end

      issues += DocumentChecker.new(document).pre_draft_issues.to_a
      CheckerIssues.new(issues)
    end

    def pre_publish_issues(params)
      issues = DocumentChecker.new(document).pre_publish_issues(params).to_a
      CheckerIssues.new(issues)
    end
  end
end
