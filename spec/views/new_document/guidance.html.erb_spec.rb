# frozen_string_literal: true

RSpec.describe "new_document/guidance.html.erb" do
  describe "guidance for publishers" do
    it "should render the associated Markdown content" do
      render
      expect(rendered).to have_selector(".gem-c-govspeak")
    end
  end
end
