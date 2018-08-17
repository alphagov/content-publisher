# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Create a detailed guide" do
  scenario "User creates a detailed guide" do
    when_i_choose_this_document_type
    then_i_am_redirected_to_another_app
  end

  def when_i_choose_this_document_type
    visit "/"
    click_on "New document"
    choose SupertypeSchema.find("guidance").label
    click_on "Continue"
    choose DocumentTypeSchema.find("detailed_guide").label
    click_on "Continue"
  end

  def then_i_am_redirected_to_another_app
    expect(page.current_path).to eq("/government/admin/detailed-guides/new")
    expect(page).to have_content("You've been redirected")
  end
end
