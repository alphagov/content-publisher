# frozen_string_literal: true

RSpec.feature "Publishing requirements" do
  scenario do
    given_there_is_a_document_that_has_unfulfilled_requirements
    when_i_visit_the_document_page
    then_i_see_the_unfulfilled_publishing_requirements

    when_i_click_on_publish
    then_i_am_on_the_document_page_with_extra_warning
    and_when_i_click_on_submit_for_2i
    then_i_am_on_the_document_page_with_extra_warning

    when_i_fix_the_unfulfilled_publishing_requirements
    then_i_see_no_unfulfilled_publishing_requirements
  end

  def given_there_is_a_document_that_has_unfulfilled_requirements
    body_field_schema = build(:field_schema, id: "body", type: "govspeak", label: "Body", validations: { "min_length" => 10 })
    document_type_schema = build(:document_type_schema, contents: [body_field_schema])
    @document = create(:document, title: "Too small", summary: "Too small", document_type: document_type_schema.id)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_see_the_unfulfilled_publishing_requirements
    expect(page).to have_content(I18n.t("documents.show.publishing_requirements.before_publishing_attempt"))

    expect(page).to have_content(I18n.t("publishing_requirements.title"))
    expect(page).to have_content(I18n.t("publishing_requirements.summary"))
    expect(page).to have_content(I18n.t("publishing_requirements.min_length", field: "body", min_length: 10))
  end

  def when_i_click_on_publish
    click_on "Publish"
  end

  def then_i_am_on_the_document_page_with_extra_warning
    expect(page).to have_content(I18n.t("documents.show.publishing_requirements.after_publishing_attempt"))
  end

  def and_when_i_click_on_submit_for_2i
    click_on "Submit for 2i"
  end

  def when_i_fix_the_unfulfilled_publishing_requirements
    stub_any_publishing_api_put_content

    click_on "Change Content"

    fill_in "document[title]", with: "A nice title of considerable length"
    fill_in "document[summary]", with: "A nice summary of considerable length"
    fill_in "document[contents][body]", with: "A very long body text."
    click_on "Save"
  end

  def then_i_see_no_unfulfilled_publishing_requirements
    expect(page).to_not have_content(I18n.t("publishing_requirements.title", min_length: 10))
    expect(page).to_not have_content(I18n.t("publishing_requirements.summary", min_length: 10))
    expect(page).to_not have_content(I18n.t("publishing_requirements.min_length", field: "Body", min_length: 10))
  end
end
