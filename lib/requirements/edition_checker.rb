module Requirements
  class EditionChecker
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def pre_preview_issues
      issues = CheckerIssues.new

      edition.image_revisions.each do |image_revision|
        issues += ImageMetadataChecker.new.pre_preview_issues(image_revision)
      end

      issues += ContentChecker.new(edition).pre_preview_issues
      issues += TagChecker.new(edition).pre_preview_issues
      issues
    end

    def pre_publish_issues(params = {})
      issues = CheckerIssues.new
      issues += ContentChecker.new(edition).pre_publish_issues
      issues += TopicChecker.new(edition).pre_publish_issues(params)
      issues += TagChecker.new(edition).pre_publish_issues
      issues
    end
  end
end
