# frozen_string_literal: true

RSpec.describe "components/_page_preview.html.erb" do
  it "renders an iframe for desktop" do
    render "components/page_preview",
           url: "http://example.com/iframe-foo",
           title: "Foo",
           base_path: "/bar",
           description: "Baz"

    expect(rendered)
      .to have_selector('iframe[src="http://example.com/iframe-foo"]')
  end

  it "renders a search snippet" do
    render "components/page_preview",
           url: "http://example.com/iframe-foo",
           title: "Foo",
           base_path: "/bar",
           description: "Baz"

    expect(rendered)
      .to have_selector("a.app-c-preview__google-title", text: "Foo - GOV.UK")
      .and have_selector("div.app-c-preview__google-url", text: "https://www.gov.uk/bar")
      .and have_selector("div.app-c-preview__google-description", text: "Baz")
  end
end
