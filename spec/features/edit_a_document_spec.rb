# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Edit a document" do
  scenario "User edits a document" do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_content_fields
    then_i_see_the_document_is_saved
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document
    body_field = { id: "body", label: "Body", type: "govspeak", validations: [] }
    document_type_schema = build(:document_type_schema, contents: [body_field])
    contents = { body: "Existing body" }
    create(:document, document_type: document_type_schema.id, contents: contents)
  end

  def when_i_go_to_edit_the_document
    visit document_path(Document.last)
    click_on "Edit document"
    expect(page).to have_content("Existing body")
  end

  def and_i_fill_in_the_content_fields
    fill_in "document[summary]", with: "A summary of the release."
    fill_in "document[contents][body]", with: "Edited body."
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Save"
  end

  def then_i_see_the_document_is_saved
    expect(page).to have_content "A summary of the release."
    expect(page).to have_content "Edited body."
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content "Preview creation successful"

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["description"]).to eq "A summary of the release."
      expect(JSON.parse(req.body)["details"]["body"]).to eq "<p>Edited body.</p>\n"
    }).to have_been_requested
  end
end
