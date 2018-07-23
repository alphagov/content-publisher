# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Create a document", type: :feature do
  scenario "User creates a document" do
    when_i_click_on_create_a_document
    and_i_choose_news
    and_i_choose_a_press_release
    and_i_fill_in_a_title
    then_the_document_exists
    and_the_document_is_in_the_draft_store
  end

  def when_i_click_on_create_a_document
    visit "/"
    click_on "New document"
  end

  def and_i_choose_news
    choose "News"
    click_on "Continue"
  end

  def and_i_choose_a_press_release
    choose "Press release"
    click_on "Continue"
  end

  def and_i_fill_in_a_title
    fill_in "document[title]", with: "A great title"

    @request = stub_publishing_api_put_content(Document.last.content_id,
                                               hash_including(title: "A great title"))

    click_on "Save"
  end

  def then_the_document_exists
    expect(Document.last.title).to eql("A great title")
    visit "/"
    expect(page).to have_content "press_release"
    expect(page).to have_content "A great title"
  end

  def and_the_document_is_in_the_draft_store
    assert_requested @request
  end
end
