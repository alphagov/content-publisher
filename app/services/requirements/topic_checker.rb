# frozen_string_literal: true

module Requirements
  class TopicChecker
    TITLE_MAX_LENGTH = 150

    attr_reader :document

    def initialize(document)
      @document = document
    end

    def pre_publish_issues(raise_exceptions: false)
      issues = []

      begin
        if document.document_type_schema.topics && document.topics.none?
          issues << Issue.new(:topics, :none)
        end
      rescue GdsApi::BaseError => e
        Rails.logger.error(e) unless raise_exceptions
        raise if raise_exceptions
      end

      CheckerIssues.new(issues)
    end
  end
end
