# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Page preview", type: :view do
  it "renders an iframe for desktop" do
    render_component(
      url: "http://example.com/iframe-foo",
      title: "Foo",
      base_path: "/bar",
      description: "Baz",
    )

    assert_select "iframe", src: "http://example.com/iframe-foo"
  end

  it "renders a search snippet" do
    render_component(
      url: "http://example.com/iframe-foo",
      title: "Foo",
      base_path: "/bar",
      description: "Baz",
    )

    assert_select "a.app-c-preview__google-title", text: "Foo - GOV.UK"
    assert_select "div.app-c-preview__google-url", text: "https://www.gov.uk/bar"
    assert_select "div.app-c-preview__google-description", text: "Baz"
  end

  def render_component(locals)
    render "components/page_preview", locals
  end
end
