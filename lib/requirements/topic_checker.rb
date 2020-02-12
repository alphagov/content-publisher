module Requirements
  class TopicChecker
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def pre_publish_issues(rescue_api_errors: true)
      issues = CheckerIssues.new

      begin
        if edition.document_type.topics && edition.topics.none?
          issues.create(:topics, :none)
        end
      rescue GdsApi::BaseError => e
        GovukError.notify(e) if rescue_api_errors
        raise unless rescue_api_errors
      end

      issues
    end
  end
end
