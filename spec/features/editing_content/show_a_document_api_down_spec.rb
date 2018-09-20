# frozen_string_literal: true

RSpec.feature "Showing a document when the API is down" do
  scenario "User views a document without API" do
    given_there_is_a_document_with_tags
    and_the_publishing_api_is_down
    when_i_visit_the_document_page
    then_i_should_see_an_error_message
  end

  def given_there_is_a_document_with_tags
    tag_schema = build(:tag_schema, type: "multi_tag")
    document_type_schema = build(:document_type_schema, tags: [tag_schema])
    tags = { tag_schema["id"] => ["a-content-id"] }
    @document = create(:document, document_type: document_type_schema.id, tags: tags)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content(I18n.t("documents.show.tags.api_down"))
  end
end
