# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Page preview", type: :view do
  it "renders an iframe for desktop" do
    render_component(
      url: "http://example.com/iframe-foo",
    )

    assert_select "iframe", src: "http://example.com/iframe-foo"
  end

  def render_component(locals)
    render "components/page_preview", locals
  end
end
