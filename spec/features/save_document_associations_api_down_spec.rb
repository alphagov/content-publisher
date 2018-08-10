# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Save document associations when the API is down" do
  scenario "User tries to save associations without API" do
    given_there_is_a_document_with_associations
    and_i_am_editing_the_associations
    and_the_publishing_api_is_down
    when_i_finish_editing_the_associations
    then_i_see_the_document_page
    and_the_preview_creation_failed
  end

  def given_there_is_a_document_with_associations
    association_schema = attributes_for(:association, type: "multi_association")
    document_type_schema = build(:document_type_schema, associations: [association_schema])
    association = { association_schema[:id] => ["a-content-id"] }
    linkable = { "content_id" => ["a-content-id"], "internal_name" => "Association" }
    publishing_api_has_linkables([linkable], document_type: association_schema[:document_type])
    @document = create(:document, document_type: document_type_schema.id, associations: association)
  end

  def and_i_am_editing_the_associations
    visit document_associations_path(@document)
  end

  def and_the_publishing_api_is_down
    @request = stub_publishing_api_put_content(Document.last.content_id, {})
    publishing_api_isnt_available
  end

  def when_i_finish_editing_the_associations
    click_on "Save"
  end

  def then_i_see_the_document_page
    expect(page).to have_content @document.title
  end

  def and_the_preview_creation_failed
    expect(@request).to have_been_requested
    expect(page).to have_content "Error creating preview"
  end
end
