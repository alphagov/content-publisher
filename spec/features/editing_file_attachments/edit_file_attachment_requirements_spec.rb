# frozen_string_literal: true

RSpec.feature "Edit a file attachment with requirements issues" do
  scenario do
    given_there_is_an_edition_with_a_file_attachment
    when_i_go_to_insert_an_attachment
    and_i_click_on_edit_file
    and_i_enter_a_blank_title_and_click_save
    then_i_see_an_error
  end

  def given_there_is_an_edition_with_a_file_attachment
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    file_attachment = create(:file_attachment_revision)
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      file_attachment_revisions: [file_attachment])
  end

  def when_i_go_to_insert_an_attachment
    visit edit_document_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Attachment"
  end

  def and_i_click_on_edit_file
    click_on "Edit file"
  end

  def and_i_enter_a_blank_title_and_click_save
    fill_in "title", with: ""
    click_on "Save"
  end

  def then_i_see_an_error
    within(".gem-c-error-summary") do
      expect(page).to have_content(
        I18n.t!("requirements.file_attachment_title.blank.form_message"),
      )
    end
  end
end
