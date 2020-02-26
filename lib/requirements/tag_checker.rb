module Requirements
  class TagChecker
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def pre_update_issues(params)
      issues = CheckerIssues.new
      edition.document_type.tags.each do |tag|
        issues += tag.pre_update_issues(edition, params)
      end
      issues
    end

    def pre_publish_issues
      issues = CheckerIssues.new
      edition.document_type.tags.each do |tag|
        issues += tag.pre_publish_issues(edition)
      end
      issues
    end
  end
end
