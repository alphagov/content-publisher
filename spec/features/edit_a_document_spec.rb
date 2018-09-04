# frozen_string_literal: true

RSpec.feature "Edit a document" do
  scenario "User edits a document" do
    given_there_is_a_document
    when_i_go_to_edit_the_document
    and_i_fill_in_the_content_fields
    then_i_see_the_document_is_saved
    and_the_preview_creation_succeeded
    and_the_content_is_now_not_reviewed
  end

  def given_there_is_a_document
    body_field_schema = build(:field_schema, id: "body", type: "govspeak")
    document_type_schema = build(:document_type_schema, contents: [body_field_schema])
    contents = { body: "Existing body" }
    create(:document, document_type: document_type_schema.id, contents: contents)
  end

  def when_i_go_to_edit_the_document
    visit document_path(Document.last)
    expect(page).to have_content("Existing body")
    click_on "Change Content"
  end

  def and_i_fill_in_the_content_fields
    fill_in "document[contents][body]", with: "Edited body."
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    click_on "Save"
  end

  def then_i_see_the_document_is_saved
    expect(page).to have_content("Edited body.")
  end

  def and_the_preview_creation_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.draft_success"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"]["body"]).to eq("<p>Edited body.</p>\n")
    }).to have_been_requested

    expect(Document.last.publication_state).to eq("sent_to_draft")
  end

  def and_the_content_is_now_not_reviewed
    expect(page).to have_button "Submit for 2i review"
  end
end
