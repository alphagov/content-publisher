# frozen_string_literal: true

RSpec.feature "Create a consultation", format: true do
  scenario "User creates a consultation" do
    when_i_choose_this_document_type
    then_i_am_redirected_to_another_app
  end

  def when_i_choose_this_document_type
    visit "/"
    click_on "New document"
    choose SupertypeSchema.find("consultations").label
    click_on "Continue"
    choose DocumentTypeSchema.find("consultation").label
    click_on "Continue"
  end

  def then_i_am_redirected_to_another_app
    expect(page.current_path).to eq("/government/admin/consultations/new")
    expect(page).to have_content("You've been redirected")
  end
end
