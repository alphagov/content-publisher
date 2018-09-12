# frozen_string_literal: true

RSpec.feature "Create a document when the API is down" do
  scenario "User creates a document without API" do
    given_i_start_to_create_a_document
    and_the_publishing_api_is_down
    when_i_submit_the_form
    then_i_see_the_document_exists
    and_the_preview_creation_failed

    when_the_api_is_up_again_and_i_click_the_retry_button
    then_the_document_is_saved_again
  end

  def given_i_start_to_create_a_document
    @schema = DocumentTypeSchema.find("news_story")
    visit "/"
    click_on "New document"
    choose SupertypeSchema.find("news").label
    click_on "Continue"
    choose @schema.label
    click_on "Continue"
  end

  def and_the_publishing_api_is_down
    @request = stub_publishing_api_put_content(Document.last.content_id,
                                               hash_including(title: "A great title"))
    publishing_api_isnt_available
  end

  def when_i_submit_the_form
    fill_in "document[title]", with: "A great title"
    click_on "Save"
  end

  def then_i_see_the_document_exists
    expect(page).to have_content("A great title")
    expect(page).to have_content(@schema.label)
    expect(Document.last.title).to eq("A great title")
  end

  def and_the_preview_creation_failed
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.draft_error.title"))
  end

  def when_the_api_is_up_again_and_i_click_the_retry_button
    @request = stub_publishing_api_put_content(Document.last.content_id,
                                               hash_including(title: "A great title"))
    click_on "Try again"
  end

  def then_the_document_is_saved_again
    expect(@request).to have_been_requested.twice
  end
end
