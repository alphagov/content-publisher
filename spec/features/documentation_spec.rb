# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Documentation" do
  scenario "GDS staff visits the docs page" do
    when_i_visit_the_documentation_page
    then_i_see_the_documentation_page
  end

  def when_i_visit_the_documentation_page
    visit "/documentation"
  end

  def then_i_see_the_documentation_page
    expect(page).to have_content(I18n.t("documentation.index.title"))
  end
end
