# frozen_string_literal: true

module Requirements
  class CheckerIssues
    include Enumerable

    attr_reader :issues
    delegate :each, to: :issues

    def initialize(issues)
      @issues = issues
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

      params.slice(:style).merge(link_options: link_options)
    end
  end
end
