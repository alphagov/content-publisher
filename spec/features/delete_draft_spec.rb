# frozen_string_literal: true

RSpec.feature "Delete draft" do
  scenario "Delete draft" do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_delete_the_draft
    then_i_see_the_document_is_gone
  end

  def given_there_is_a_document
    @document = create(:document)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_delete_the_draft
    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def then_i_see_the_document_is_gone
    expect(page).to have_current_path(documents_path)
    expect(page).to_not have_content @document.title
  end
end
