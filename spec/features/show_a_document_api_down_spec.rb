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
    @document = create(:document, :with_associations_in_schema)

    @document.document_type_schema.associations.each do |schema|
      publishing_api_has_linkables([], document_type: schema.document_type)
    end

    associations = @document.document_type_schema.associations.map do |schema|
      [schema.id, [SecureRandom.uuid]]
    end

    @document.update(associations: Hash[associations])

    publishing_api_isnt_available
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_should_see_an_error_message
    count = @document.document_type_schema.associations.count
    expect(page).to have_content("This content isn't available right now.", count: count)
  end
end
