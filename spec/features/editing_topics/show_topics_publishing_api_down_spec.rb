# frozen_string_literal: true

RSpec.feature "Showing topics when the Publishing API is down" do
  scenario do
    given_there_is_a_document
    and_the_publishing_api_is_down
    when_i_visit_the_document_page
    then_i_should_see_an_error_message
  end

  def given_there_is_a_document
    document_type = build(:document_type, topics: true)
    @document = create(:document, document_type_id: document_type.id)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_should_see_an_error_message
    within("#topics") do
      expect(page).to have_content(I18n.t!("documents.show.topics.api_down"))
    end
  end
end
