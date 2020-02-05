# frozen_string_literal: true

module Requirements
  class TagChecker
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def pre_publish_issues
      issues = CheckerIssues.new

      if should_have_primary_org? && has_no_primary_org?
        issues << Issue.new(:primary_publishing_organisation, :blank)
      end

      issues
    end

  private

    def should_have_primary_org?
      edition.document_type.tags.map(&:id)
       .include?("primary_publishing_organisation")
    end

    def has_no_primary_org?
      edition.primary_publishing_organisation_id.blank?
    end
  end
end
