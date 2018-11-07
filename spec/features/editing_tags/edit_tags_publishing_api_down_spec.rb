# frozen_string_literal: true

RSpec.feature "Edit tags when the API is down" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_the_publishing_api_is_down
    and_i_try_to_change_the_tags
    then_i_should_see_an_error_message
  end

  def given_there_is_a_document
    tag_schema = build(:tag_schema, type: "multi_tag")
    document_type_schema = build(:document_type_schema, tags: [tag_schema])
    publishing_api_has_linkables([], document_type: tag_schema["document_type"])
    @document = create(:document, document_type: document_type_schema.id)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_try_to_change_the_tags
    click_on "Change Tags"
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content(I18n.t("document_tags.edit.api_down"))
  end
end
