# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Edit a document", type: :feature do
  scenario "User edits a document" do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_a_body_text
    then_the_document_is_saved
  end

  def given_there_is_a_document
    create :document, document_type: "press_release"
  end

  def when_i_go_to_edit_the_document
    visit edit_document_path(Document.last)
  end

  def and_i_fill_in_a_body_text
    fill_in "document[contents][body]", with: "The document body"
    click_on "Save"
  end

  def then_the_document_is_saved
    expect(Document.last.contents["body"]).to eql("The document body")
  end
end
