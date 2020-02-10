# frozen_string_literal: true

module Requirements
  class TagChecker
    attr_reader :edition, :revision

    def initialize(edition, revision = nil)
      @edition = edition
      @revision = revision || edition.revision
    end

    def pre_update_issues(params)
      issues = CheckerIssues.new

      if missing_primary_org?(params)
        issues.create(:primary_publishing_organisation, :blank)
      end

      issues
    end

    def pre_publish_issues
      pre_update_issues(edition.tags.symbolize_keys)
    end

  private

    def should_have_primary_org?
      edition.document_type.tags.map(&:id)
       .include?("primary_publishing_organisation")
    end

    def missing_primary_org?(params)
      return false unless should_have_primary_org?

      params[:primary_publishing_organisation].blank?
    end
  end
end
