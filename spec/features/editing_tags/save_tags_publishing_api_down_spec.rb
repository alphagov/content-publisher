# frozen_string_literal: true

RSpec.feature "Save document tags when the API is down" do
  scenario do
    given_there_is_a_document_with_tags
    and_i_am_on_the_tags_page
    and_the_publishing_api_is_down
    when_i_click_the_save_button
    then_i_see_the_document_page
    and_the_preview_creation_failed
  end

  def given_there_is_a_document_with_tags
    tag_schema = build(:tag_schema, type: "multi_tag")
    document_type_schema = build(:document_type_schema, tags: [tag_schema])
    tag = { tag_schema["id"] => ["a-content-id"] }
    publishing_api_has_linkables([], document_type: tag_schema["document_type"])
    @document = create(:document, document_type: document_type_schema.id, tags: tag)
  end

  def and_i_am_on_the_tags_page
    visit document_tags_path(@document)
  end

  def and_the_publishing_api_is_down
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    publishing_api_isnt_available
  end

  def when_i_click_the_save_button
    click_on "Save"
  end

  def then_i_see_the_document_page
    expect(current_path).to eq document_path(@document)
  end

  def and_the_preview_creation_failed
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.draft_error.title"))
  end
end
