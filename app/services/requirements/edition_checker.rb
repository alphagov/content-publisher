# frozen_string_literal: true

module Requirements
  class EditionChecker
    attr_reader :edition, :revision

    def initialize(edition, revision = nil)
      @edition = edition
      @revision = revision || edition.revision
    end

    def pre_preview_issues
      issues = CheckerIssues.new

      revision.image_revisions.each do |image|
        issues += ImageRevisionChecker.new(image).pre_preview_issues
      end

      issues += ContentChecker.new(edition, revision).pre_preview_issues
      issues
    end

    def pre_publish_issues(params = {})
      issues = CheckerIssues.new
      issues += ContentChecker.new(edition, revision).pre_publish_issues
      issues += TopicChecker.new(edition.document).pre_publish_issues(params)
      issues += TagChecker.new(edition, revision).pre_publish_issues
      issues
    end
  end
end
