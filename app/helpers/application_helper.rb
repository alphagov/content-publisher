# frozen_string_literal: true

module ApplicationHelper
  def govspeak_to_html(govspeak)
    raw(Govspeak::Document.new(govspeak).to_html) # rubocop:disable Rails/OutputSafety
  end

  def render_back_link(options)
    render("govuk_publishing_components/components/back_link", options)
  end

  def strip_scheme_from_url(url)
    url.sub(/^https?\:\/\//, "")
  end

  def escape_and_link(unsafe_text)
    Rinku.auto_link(html_escape(unsafe_text))
  end
end
