# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Edit a document", type: :feature do
  scenario "User edits a document" do
    when_i_click_on_create_a_document
    and_i_choose_news
    and_i_choose_a_press_release
    and_i_fill_in_a_body_text
    then_the_document_is_saved
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

  def and_i_fill_in_a_body_text
    fill_in "document[contents][body]", with: "The document body"
    click_on "Save"
  end

  def then_the_document_is_saved
    expect(Document.last.contents["body"]).to eql("The document body")
  end
end
