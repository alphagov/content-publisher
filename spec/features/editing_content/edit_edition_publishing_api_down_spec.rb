# frozen_string_literal: true

RSpec.feature "Edit an edition when the Publishing API is down" do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_the_publishing_api_is_down
    and_i_try_preview_the_edition
    then_i_see_an_error_message
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_go_to_edit_the_edition
    visit edit_document_path(@edition.document)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
    click_on "Save"
  end

  def and_i_try_preview_the_edition
    click_on "Preview"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("documents.show.flashes.preview_error.title"))
  end
end
