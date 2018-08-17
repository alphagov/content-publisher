# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Publish validations" do
  scenario "A document is validated" do
    given_there_is_an_invalid_document
    when_i_visit_the_document_page
    then_i_see_some_validation_errors
    when_i_make_the_document_valid
    then_i_see_no_validation_errors
  end

  def given_there_is_an_invalid_document
    @title_validation = build(:validation_schema, type: "title_min_length", settings: { "limit" => 10 })
    @summary_validation = build(:validation_schema, type: "summary_min_length", settings: { "limit" => 10 })
    @body_validation = build(:validation_schema, id: "body", type: "min_length", settings: { "limit" => 10 })
    body_field_schema = build(:field_schema, id: "body", type: "govspeak")

    document_type_schema = build(:document_type_schema, contents: [body_field_schema],
                                 validations: [@title_validation, @summary_validation, @body_validation])

    @document = create(:document, title: "foo", summary: nil, document_type: document_type_schema.id)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_see_some_validation_errors
    expect(page).to have_content @title_validation["message"]
    expect(page).to have_content @summary_validation["message"]
    expect(page).to have_content @body_validation["message"]
  end

  def when_i_make_the_document_valid
    stub_any_publishing_api_put_content
    base_path = "#{@document.document_type_schema.path_prefix}/a-nice-title-of-considerable-length"
    publishing_api_has_lookups(base_path => "foo")

    click_on "Edit document"
    fill_in "document[title]", with: "A nice title of considerable length"
    fill_in "document[summary]", with: "A nice summary of considerable length"
    fill_in "document[contents][body]", with: "A very long body text."
    click_on "Save"
  end

  def then_i_see_no_validation_errors
    expect(page).to_not have_content @title_validation["message"]
    expect(page).to_not have_content @summary_validation["message"]
    expect(page).to_not have_content @body_validation["message"]
  end
end
