# frozen_string_literal: true

RSpec.feature "Upload a file attachment with requirements issues", js: true do
  scenario do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_go_to_insert_an_attachment
    and_i_upload_an_invalid_file_attachment
    then_i_see_an_error
  end

  def given_there_is_an_edition
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field], images: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_go_to_edit_the_edition
    visit document_path(@edition.document)
    click_on "Edit Content"
  end

  def and_i_go_to_insert_an_attachment
    find("markdown-toolbar details").click
    click_on "Attachment"
  end

  def and_i_upload_an_invalid_file_attachment
    @attachment_filename = "bad_file.rb"
    find('form input[type="file"]').set(Rails.root.join(file_fixture(@attachment_filename)))
    fill_in "title", with: "A title"
    click_on "Upload"
  end

  def then_i_see_an_error
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.file_attachment_upload.unsupported_type.form_message"))
    end
  end
end
