# frozen_string_literal: true

RSpec.feature "Drafting requirements" do
  scenario do
    given_there_is_a_document_with_no_content
    when_i_visit_the_edit_document_page
    and_save_without_inputting_anything
    then_i_should_see_an_error_message_regarding_a_missing_title

#    when_i_visit_the_edit_document_page
#    and_save_a_title_which_exceeds_the_max_length
#    then_i_should_see_error_messages_regarding_max_length
#
#    when_i_visit_the_edit_document_page
#    and_save_a_title_which_has_multiple_lines
#    then_i_should_see_error_messages_regarding_multiple_lines
  end

  def given_there_is_a_document_with_no_content
    body_field_schema = build(:field_schema, id: "body", type: "govspeak")
    document_type_schema = build(:document_type_schema, contents: [body_field_schema])
    create(:document, document_type: document_type_schema.id, title: "")
  end

  def when_i_visit_the_edit_document_page
    visit edit_document_path(Document.last)
  end

  def and_save_without_inputting_anything
    click_on "Save"
  end

  def then_i_should_see_an_error_message_regarding_a_missing_title
    within find(".gem-c-error-summary") do
      expect(page).to have_content(
        I18n.t(
          "documents.edit.flashes.drafting_requirements.missing",
          field: "title",
        ),
      )
    end
    within find(".govuk-form-group--error") do
      expect(page).to have_content(
        I18n.t(
          "documents.edit.flashes.drafting_requirements.missing",
          field: "title",
        ),
      )
    end
  end

  def and_save_a_title_which_has_multiple_lines
    fill_in "document[title]", with: "MULTIPLE LINES ARGHHH \r\n 2nd line"
    click_on "Save"
  end

  def then_i_should_see_error_messages_regarding_multiple_lines
    within find(".gem-c-error-summary") do
      expect(page).to have_content(
        I18n.t(
          "documents.edit.flashes.drafting_requirements.multiple_lines",
          field: "title",
        ),
      )
    end
    within find(".govuk-form-group--error") do
      expect(page).to have_content(
        I18n.t(
          "documents.edit.flashes.drafting_requirements.multiple_lines",
          field: "title",
        ),
      )
    end
  end

  def and_save_a_title_which_exceeds_the_max_length
    fill_in "document[title]", with: (1..200).to_a.join(" ")
    click_on "Save"
  end

  def then_i_should_see_error_messages_regarding_max_length
    within find(".gem-c-error-summary") do
      expect(page).to have_content(
        I18n.t(
          "documents.edit.flashes.drafting_requirements.max_length",
          field: "title",
          max_length: DraftingRequirements::TITLE_MAX_LENGTH,
        ),
      )
    end
    within find(".govuk-form-group--error") do
      expect(page).to have_content(
        I18n.t(
          "documents.edit.flashes.drafting_requirements.max_length",
          field: "title",
          max_length: DraftingRequirements::TITLE_MAX_LENGTH,
        ),
      )
    end
  end
end
