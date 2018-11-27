# frozen_string_literal: true

module Requirements
  class TopicChecker
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def pre_publish_issues(rescue_api_errors: true)
      issues = []

      begin
        if document.document_type_schema.topics && document.topics.none?
          issues << Issue.new(:topics, :none)
        end
      rescue GdsApi::BaseError => e
        GovukError.notify(e) if rescue_api_errors
        raise unless rescue_api_errors
      end

      CheckerIssues.new(issues)
    end
  end
end
