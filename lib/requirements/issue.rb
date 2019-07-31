# frozen_string_literal: true

module Requirements
  class Issue
    attr_accessor :field, :issue_key, :context

    def initialize(field, issue_key, **context)
      @field = field.to_sym
      @issue_key = issue_key
      @context = context
    end

    def message(style:)
      I18n.t("requirements.#{field}.#{issue_key}.#{style}_message", context)
    end

    def to_item(link_options: {}, style: "form")
      link_options = link_options.call(context) if link_options.is_a?(Proc)

      {
        text: message(style: style),
        href: link_options[:href],
        target: link_options[:target],
      }
    end
  end
end
