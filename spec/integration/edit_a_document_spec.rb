# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Edit a document", type: :feature do
  scenario "User edits a document" do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_fields
    then_i_see_the_document_is_saved
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document
    create :document, document_type: "press_release"
  end

  def when_i_go_to_edit_the_document
    visit document_path(Document.last)
    click_on "Edit"
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
  end

  def and_i_fill_in_the_fields
    fill_in "document[contents][body]", with: "The document body"
    fill_in "document[summary]", with: "A summary of the release."
    click_on "Save"
  end

  def then_i_see_the_document_is_saved
    expect(Document.last.summary).to eql("A summary of the release.")
    expect(page).to have_content "The document body"
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content "Preview creation successful"

    expect(a_request(:put, /content/).with { |req|
      expect(req.body).to be_valid_against_schema("news_article")
      expect(JSON.parse(req.body)["details"]["body"]).to eq "The document body"
    }).to have_been_requested
  end
end
