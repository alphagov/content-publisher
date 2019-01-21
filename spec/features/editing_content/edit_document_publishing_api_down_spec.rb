# frozen_string_literal: true

RSpec.feature "Edit a document when the Publishing API is down" do
  scenario do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_the_publishing_api_is_down
    and_i_try_preview_the_document
    then_i_see_an_error_message
  end

  def given_there_is_a_document
    @document = create(:document, :with_current_edition)
  end

  def when_i_go_to_edit_the_document
    visit edit_document_path(@document)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
    click_on "Save"
  end

  def and_i_try_preview_the_document
    click_on "Preview"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("documents.show.flashes.preview_error.title"))
  end
end
