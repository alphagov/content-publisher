# frozen_string_literal: true

module Versioned
  module Requirements
    class EditionChecker
      attr_reader :edition, :revision

      def initialize(edition, revision = nil)
        @edition = edition
        @revision = revision || edition.revision
      end

      def pre_preview_issues
        issues = []

        revision.image_revisions.each do |image|
          issues += ImageRevisionChecker.new(image).pre_preview_issues.to_a
        end

        issues += ContentChecker.new(edition, revision).pre_preview_issues.to_a
        ::Requirements::CheckerIssues.new(issues)
      end

      def pre_publish_issues(params = {})
        issues = []
        issues += ContentChecker.new(edition, revision).pre_publish_issues.to_a
        issues += ::Requirements::TopicChecker.new(edition.document).pre_publish_issues(params).to_a
        ::Requirements::CheckerIssues.new(issues)
      end
    end
  end
end
