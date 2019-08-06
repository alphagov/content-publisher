# frozen_string_literal: true

RSpec::Matchers.define :have_issue do |field, key, context = {}|
  context[:styles] ||= %i[form]

  match do |issues|
    issue = issues.find do |actual_issue|
      actual_issue.field == field && actual_issue.issue_key == key &&
        actual_issue.context == context.except(:styles)
    end

    # use the issue message to do a deep check (include context)
    # this also means we cover all the translations being defined
    issue && context[:styles].all? do |style|
      expected = I18n.t!("requirements.#{field}.#{key}.#{style}_message",
                         context.except(:styles).merge(force_raise: true))

      issue.message(style: style) == expected
    end
  end

  failure_message do |actual_issues|
    issue = Requirements::Issue.new(field, key, context.except(:styles))
    "expected #{actual_issues.inspect} to have issue #{issue.inspect}"
  end
end
