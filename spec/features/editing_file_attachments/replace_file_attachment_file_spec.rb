# frozen_string_literal: true

RSpec.feature "Replace a file attachment file" do
  scenario do
    given_there_is_an_edition_with_an_attachment
    when_i_click_to_insert_an_attachment
    and_i_click_on_edit_file
    and_i_upload_a_new_attachment_file_with_the_same_filename_and_click_save
  end

  def given_there_is_an_edition_with_an_attachment
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    @attachment_filename = "replacement-text-file.txt"
    @attachment_revision = create(:file_attachment_revision,
                                  :on_asset_manager,
                                  title: "A title",
                                  filename: @attachment_filename)
    @edition = create(:edition,
                      document_type_id: document_type.id,
                      file_attachment_revisions: [@attachment_revision])
  end

  def when_i_click_to_insert_an_attachment
    visit edit_document_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Attachment"
    expect(page).to have_content("0 Bytes")
  end

  def and_i_click_on_edit_file
    click_on "Edit file"
  end

  def and_i_upload_a_new_attachment_file_with_the_same_filename_and_click_save
    find('form input[type="file"]').set(Rails.root.join(file_fixture(@attachment_filename)))
    click_on "Save"
  end
end
