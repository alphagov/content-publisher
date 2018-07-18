# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Create a document", type: :feature, skip: true do
  scenario "User creates a document" do
    when_i_click_on_create_a_document
    and_i_choose_news_article
    and_i_fill_in_a_title
    then_the_document_exists
  end

  def when_i_click_on_create_a_document
    visit "/"
    click_on "New document"
  end

  def and_i_choose_news_article
    click_on "Create news article"
  end

  def and_i_fill_in_a_title
    fill_in "document[title]", with: "A great title"
    click_on "Save"
  end

  def then_the_document_exists
    expect(Document.last.title).to eql("A great title")
    visit "/"
    expect(page).to have_content "A great title"
  end
end
