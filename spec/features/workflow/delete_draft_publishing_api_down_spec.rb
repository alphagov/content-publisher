# frozen_string_literal: true

RSpec.feature "Delete draft when the Publishing API is down" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_the_publishing_api_is_down
    and_i_delete_the_draft
    then_i_see_the_deletion_failed
    when_the_api_is_up_and_i_try_again
    then_i_see_the_document_is_gone
  end

  def given_there_is_a_document
    @document = create(:document)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def when_the_api_is_up_and_i_try_again
    @request = stub_publishing_api_discard_draft(@document.content_id)
    click_on "Try again"
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_i_delete_the_draft
    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def then_i_see_the_deletion_failed
    expect(page).to have_content(I18n.t!("documents.show.flashes.delete_draft_error.title"))
    expect(page).to have_content(@document.title)
  end

  def then_i_see_the_document_is_gone
    expect(page).to have_current_path(documents_path)
    expect(page).to_not have_content @document.title
  end
end
