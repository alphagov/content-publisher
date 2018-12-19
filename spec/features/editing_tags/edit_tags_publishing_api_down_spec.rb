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
    tag_field = build(:tag_field, type: "multi_tag")
    document_type = build(:document_type, tags: [tag_field])
    publishing_api_has_linkables([], document_type: tag_field.document_type)
    @document = create(:document, document_type_id: document_type.id)
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
    expect(page).to have_content(I18n.t!("tags.edit.api_down"))
  end
end
