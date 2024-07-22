RSpec.feature "Replace a file attachment file", :js do
  scenario "inline" do
    given_there_is_an_edition_with_an_attachment
    when_i_click_to_insert_an_attachment
    and_i_click_on_edit_file
    and_i_upload_a_replacement_attachment_file
    and_i_click_save
    then_i_see_the_replacement_file
    and_i_see_the_timeline_entry
  end

  scenario "featured" do
    given_there_is_an_edition_with_featured_attachments
    when_i_go_to_edit_an_attachment
    and_i_upload_a_replacement_attachment_file
    and_i_click_save
    then_i_see_the_replacement_file
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition_with_an_attachment
    @attachment_revision = create(:file_attachment_revision,
                                  :on_asset_manager,
                                  filename: attachment_filename)

    @edition = create(:edition,
                      document_type: build(:document_type, :with_body),
                      file_attachment_revisions: [@attachment_revision])
  end

  def given_there_is_an_edition_with_featured_attachments
    @attachment_revision = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type: build(:document_type, attachments: "featured"),
                      file_attachment_revisions: [@attachment_revision])
  end

  def when_i_click_to_insert_an_attachment
    visit content_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Attachment"
    expect(page).to have_content("74 Bytes")
  end

  def when_i_go_to_edit_an_attachment
    visit featured_attachments_path(@edition.document)
    click_on "Edit attachment"
  end

  def and_i_click_on_edit_file
    click_on "Edit file"
  end

  def and_i_upload_a_replacement_attachment_file
    stub_publishing_api_put_content(@edition.content_id, {})
    stub_asset_manager_receives_an_asset(filename: attachment_filename)
    find('form input[type="file"]').set(Rails.root.join(file_fixture(attachment_filename)))
  end

  def and_i_click_save
    click_on "Save"
  end

  def then_i_see_the_replacement_file
    expect(page).to have_content("58 Bytes")
    expect(page).not_to have_content("74 Bytes")
  end

  def and_i_see_the_timeline_entry
    visit document_path(@edition.document)
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.file_attachment_updated")
  end

  def attachment_filename
    "replacement-text-file-58bytes.txt"
  end
end
