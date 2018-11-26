# frozen_string_literal: true

module ApplicationHelper
  def govspeak_to_html(govspeak)
    raw(Govspeak::Document.new(govspeak).to_html) # rubocop:disable Rails/OutputSafety
  end

  def render_back_link(options)
    render("govuk_publishing_components/components/back_link", options)
  end
end
