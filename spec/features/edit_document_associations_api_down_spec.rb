# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Edit document associations when the API is down" do
  scenario "User edits associations without pubishing" do
    given_there_is_a_document_with_associations
    and_the_publishing_api_is_down
    when_i_visit_the_document_page
    and_i_click_on_edit_associations
    then_i_should_see_an_error_message
  end

  def given_there_is_a_document_with_associations
    @document = create(:document, :with_associations_in_schema)

    @document.document_type_schema.associations.each do |schema|
      publishing_api_has_linkables([], document_type: schema.document_type)
    end

    publishing_api_isnt_available
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
    count = @document.document_type_schema.associations.count
    expect(page).to have_content("This content can't be edited right now.", count: count)
  end
end
