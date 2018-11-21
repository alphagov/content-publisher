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
      map { |issue| issue.to_item(**params) }
    end

    def items_for(field, params = {})
      select { |issue| issue.field == field }
        .map { |issue| issue.to_item(**params) }
    end
  end
end
