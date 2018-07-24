# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Create a document when the API is down", type: :feature do
  scenario "User creates a document without publishing" do
    given_i_start_to_create_a_document
    and_the_publishing_api_is_down
    when_i_submit_the_form
    then_i_see_the_document_exists
    and_the_preview_creation_failed
  end

  def given_i_start_to_create_a_document
    visit "/"
    click_on "New document"

    choose "News"
    click_on "Continue"

    choose "Press release"
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
    expect(Document.last.title).to eq "A great title"
    expect(page).to have_content "press_release"
    expect(page).to have_content "A great title"
  end

  def and_the_preview_creation_failed
    assert_requested @request
    expect(page).to have_content "Error creating preview"
  end
end
