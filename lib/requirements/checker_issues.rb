module Requirements
  class CheckerIssues
    include Enumerable

    delegate :each, :empty?, to: :issues
    attr_reader :issues

    def initialize(issues = [])
      @issues = issues
    end

    def push(*issues)
      self.issues.push(*issues)
    end

    def create(...)
      issues << Issue.new(...)
    end

    def items(params = {})
      map { |issue| issue.to_item(**issue_item_params(issue, params)) }
    end

    def items_for(field, params = {})
      select { |issue| issue.field == field }
        .map { |issue| issue.to_item(**issue_item_params(issue, params)) }
    end

  private

    def issue_item_params(issue, params)
      link_options = params.dig(:link_options, issue.field) || {}

      params.slice(:style).merge(link_options:)
    end
  end
end
