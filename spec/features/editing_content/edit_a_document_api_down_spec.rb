# frozen_string_literal: true

RSpec.feature "Edit a document when the API is down" do
  scenario do
    given_there_is_a_document
    and_the_publishing_api_is_down

    when_i_go_to_edit_the_document
    and_i_submit_the_form
    then_i_see_the_preview_creation_failed

    when_the_api_is_up_again_and_i_click_the_retry_button
    then_the_document_is_saved_again
  end

  def given_there_is_a_document
    @document = create(:document)
  end

  def when_i_go_to_edit_the_document
    visit edit_document_path(@document)
  end

  def and_the_publishing_api_is_down
    @request = stub_any_publishing_api_put_content
    publishing_api_isnt_available
  end

  def and_i_submit_the_form
    fill_in "document[title]", with: "A great title"
    click_on "Save"
  end

  def then_i_see_the_preview_creation_failed
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.draft_error.title"))
  end

  def when_the_api_is_up_again_and_i_click_the_retry_button
    @request = stub_any_publishing_api_put_content
    click_on "Try again"
  end

  def then_the_document_is_saved_again
    expect(@request).to have_been_requested.twice
  end
end
