# frozen_string_literal: true

module Requirements
  class TagChecker
    attr_reader :edition, :revision

    def initialize(edition, revision = nil)
      @edition = edition
      @revision = revision || edition.revision
    end

    def pre_publish_issues
      issues = []
      if edition.document_type.tags.map(&:id).include?("primary_publishing_organisation")
        if revision.primary_publishing_organisation_id.blank?
          issues << Issue.new(:primary_publishing_organisation, :blank)
        end
      end

      CheckerIssues.new(issues)
    end
  end
end
