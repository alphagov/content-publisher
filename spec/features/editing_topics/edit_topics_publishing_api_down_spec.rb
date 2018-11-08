# frozen_string_literal: true

RSpec.feature "Edit tags when the Publishing API is down" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_the_publishing_api_is_down
    and_i_try_to_change_the_topics
    then_i_see_an_error_message
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, topics: true)
    document = create(:document, document_type: document_type_schema.id)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_document_page
    visit document_path(Document.last)
  end

  def and_i_try_to_change_the_topics
    click_on "Change Topics"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t("document_topics.edit.api_down"))
  end
end
