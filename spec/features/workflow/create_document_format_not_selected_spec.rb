# frozen_string_literal: true

RSpec.feature "Creating a document without selecting a format" do
  scenario do
    when_i_dont_choose_a_supertype
    then_i_see_an_error_to_choose_a_supertype
    when_i_choose_a_supertype
    and_i_dont_choose_a_document_type
    then_i_see_an_error_to_choose_a_document_type
  end

  def when_i_dont_choose_a_supertype
    visit root_path
    click_on "Create new document"
    click_on "Continue"
  end

  def then_i_see_an_error_to_choose_a_supertype
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("new_document.choose_supertype.flashes.not_selected.title"))
      expect(page).to have_content(I18n.t!("new_document.choose_supertype.flashes.not_selected.message"))
    end
  end

  def when_i_choose_a_supertype
    choose Supertype.all.first.label
    click_on "Continue"
  end

  def and_i_dont_choose_a_document_type
    click_on "Continue"
  end

  def then_i_see_an_error_to_choose_a_document_type
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("new_document.choose_document_type.flashes.not_selected.title"))
      expect(page).to have_content(I18n.t!("new_document.choose_document_type.flashes.not_selected.message"))
    end
  end
end
