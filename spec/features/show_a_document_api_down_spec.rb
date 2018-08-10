# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Showing a document when the API is down" do
  scenario "User views a document without API" do
    given_there_is_a_document_with_associations
    and_the_publishing_api_is_down
    when_i_visit_the_document_page
    then_i_should_see_an_error_message
  end

  def given_there_is_a_document_with_associations
    association_schema = build(:association_schema, type: "multi_association")
    document_type_schema = build(:document_type_schema, associations: [association_schema])
    associations = { association_schema["id"] => ["a-content-id"] }
    @document = create(:document, document_type: document_type_schema.id, associations: associations)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content("This content isn't available right now.")
  end
end
