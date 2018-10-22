# frozen_string_literal: true

RSpec.feature "Publishing requirements" do
  scenario do
    given_there_is_a_document
    when_the_document_has_no_summary
    and_i_visit_the_document_page
    then_i_see_a_hint_to_enter_a_summary

    when_the_document_has_a_blank_field
    and_i_visit_the_document_page
    then_i_see_a_hint_to_enter_the_field

    when_i_try_to_publish_the_document
    then_i_see_an_error_to_enter_a_summary
    and_i_see_an_error_to_enter_the_field

    when_i_try_to_submit_the_document_for_2i
    then_i_see_an_error_to_enter_a_summary
    and_i_see_an_error_to_enter_the_field
  end

  def given_there_is_a_document
    field_schema = build(:field_schema, id: "field", type: "govspeak", label: "Field")
    document_type_schema = build(:document_type_schema, contents: [field_schema])
    @document = create(:document, document_type: document_type_schema.id)
  end

  def and_i_visit_the_document_page
    stub_any_publishing_api_put_content
    click_on "Save"
  end

  def when_the_document_has_no_summary
    visit document_path(@document)
    click_on "Change Content"
    fill_in "document[summary]", with: ""
  end

  def when_the_document_has_a_blank_field
    visit document_path(@document)
    click_on "Change Content"
    fill_in "document[contents][field]", with: ""
  end

  def then_i_see_a_hint_to_enter_a_summary
    within(".app-c-notice") do
      expect(page).to have_content(I18n.t("publishing_requirements.presence", field: "summary"))
    end
  end

  def then_i_see_a_hint_to_enter_the_field
    within(".app-c-notice") do
      expect(page).to have_content(I18n.t("publishing_requirements.field_presence", field: "field"))
    end
  end

  def when_i_try_to_publish_the_document
    click_on "Publish"
  end

  def when_i_try_to_submit_the_document_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_an_error_to_enter_a_summary
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t("publishing_requirements.presence", field: "summary"))
    end
  end

  def and_i_see_an_error_to_enter_the_field
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t("publishing_requirements.field_presence", field: "field"))
    end
  end
end
