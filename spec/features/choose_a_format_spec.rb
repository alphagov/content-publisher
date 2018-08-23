# frozen_string_literal: true

RSpec.feature "Choosing a format" do
  scenario "User forgets to choose a format" do
    when_i_dont_choose_a_supertype
    then_i_see_a_supertype_error
    when_i_choose_a_supertype
    and_i_dont_choose_a_document_type
    then_i_see_a_document_type_error
  end

  def when_i_dont_choose_a_supertype
    visit "/"
    click_on "New document"
    click_on "Continue"
  end

  def then_i_see_a_supertype_error
    expect(page).to have_content(I18n.t("new_document.choose_supertype.flashes.choose_error"))
  end

  def when_i_choose_a_supertype
    choose SupertypeSchema.all.first.label
    click_on "Continue"
  end

  def and_i_dont_choose_a_document_type
    click_on "Continue"
  end

  def then_i_see_a_document_type_error
    expect(page).to have_content(I18n.t("new_document.choose_document_type.flashes.choose_error"))
  end
end
