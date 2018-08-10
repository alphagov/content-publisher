# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Create a policy paper" do
  scenario "User creates a policy paper" do
    when_i_choose_this_document_type
    then_i_am_redirected_to_another_app
  end

  def when_i_choose_this_document_type
    visit "/"
    click_on "New document"

    choose "Policy"
    click_on "Continue"

    choose "Policy paper"
    click_on "Continue"
  end

  def then_i_am_redirected_to_another_app
    expect(page.current_path).to eql '/government/admin/publications/new'
    expect(page).to have_content "You've been redirected"
  end
end
