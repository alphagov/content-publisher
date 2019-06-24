# frozen_string_literal: true

module ApplicationHelper
  def govspeak_to_html(govspeak)
    # We expect all the govspeak through this to be commited code where we
    # verify the safety
    raw(Govspeak::Document.new(govspeak, sanitize: false).to_html) # rubocop:disable Rails/OutputSafety
  end

  def render_back_link(options)
    render("govuk_publishing_components/components/back_link", options)
  end

  def render_govspeak(content)
    render "govuk_publishing_components/components/govspeak" do
      govspeak_to_html(content)
    end
  end

  def strip_scheme_from_url(url)
    url.sub(/^https?\:\/\//, "")
  end

  def escape_and_link(unsafe_text)
    Rinku.auto_link(html_escape(unsafe_text), :all, 'class="govuk-link"')
  end

  def name_or_fallback(user)
    user&.name || I18n.t("documents.unknown_user")
  end

  def track_requirements(issue_items)
    issue_items.map do |issue_item|
      issue_item.merge(
        data_attributes: {
          "gtm" => "requirements-issue",
          "gtm-value" => issue_item[:text],
          "gtm-visibility-tracking" => true,
        },
      )
    end
  end
end
