# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Edit document associations when the API is down" do
  scenario "User tries to edit associations without API" do
    given_there_is_a_document
    and_the_publishing_api_is_down
    when_i_visit_the_document_page
    and_i_click_on_edit_associations
    then_i_should_see_an_error_message
  end

  def given_there_is_a_document
    association_schema = build(:association_schema, type: "multi_association")
    document_type_schema = build(:document_type_schema, associations: [association_schema])
    publishing_api_has_linkables([], document_type: association_schema["document_type"])
    @document = create(:document, document_type: document_type_schema.id)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_edit_associations
    click_on "Edit associations"
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content("This content can't be edited right now.")
  end
end
