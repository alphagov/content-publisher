# frozen_string_literal: true

module Requirements
  class Issue
    attr_accessor :field, :issue_key, :context

    def initialize(field, issue_key, **context)
      @field = field.to_sym
      @issue_key = issue_key
      @context = context
    end

    def message(verbosity_key)
      I18n.t("requirements.#{field}.#{issue_key}.#{verbosity_key}_message", context)
    end

    def to_item(hrefs: {}, verbose: false)
      {
        text: message(verbose ? "long" : "short"),
        href: hrefs[field],
      }
    end
  end
end
