# frozen_string_literal: true

RSpec.feature "Publish validations" do
  scenario "A document is validated" do
    given_there_is_an_invalid_document
    when_i_visit_the_document_page
    then_i_see_the_validation_warnings
    when_i_fix_the_validation_warnings
    then_i_see_no_validation_warnings
  end

  def given_there_is_an_invalid_document
    body_field_schema = build(:field_schema, id: "body", type: "govspeak", label: "Body", validations: { "min_length" => 10 })
    document_type_schema = build(:document_type_schema, contents: [body_field_schema])
    @document = create(:document, title: "Too small", summary: "Too small", document_type: document_type_schema.id)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_see_the_validation_warnings
    expect(page).to have_content(I18n.t("validations.title", min_length: 10))
    expect(page).to have_content(I18n.t("validations.summary", min_length: 10))
    expect(page).to have_content(I18n.t("validations.min_length", field: "Body", min_length: 10))
  end

  def when_i_fix_the_validation_warnings
    stub_any_publishing_api_put_content

    click_on "Change Content"

    fill_in "document[title]", with: "A nice title of considerable length"
    fill_in "document[summary]", with: "A nice summary of considerable length"
    fill_in "document[contents][body]", with: "A very long body text."
    click_on "Save"
  end

  def then_i_see_no_validation_warnings
    expect(page).to_not have_content(I18n.t("validations.title", min_length: 10))
    expect(page).to_not have_content(I18n.t("validations.summary", min_length: 10))
    expect(page).to_not have_content(I18n.t("validations.min_length", field: "Body", min_length: 10))
  end
end
