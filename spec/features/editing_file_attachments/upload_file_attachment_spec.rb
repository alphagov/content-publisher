RSpec.feature "Upload file attachment", js: true do
  scenario "inline attachment" do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_go_to_insert_an_attachment
    and_i_select_a_file_to_upload
    and_i_upload_the_file_attachment
    then_i_can_see_the_attachment
    and_i_can_see_an_action_to_preview_the_attachment
    and_i_see_the_timeline_entry
  end

  scenario "featured attachment" do
    given_there_is_an_edition_that_allows_featured_attachments
    when_i_visit_the_summary_page
    and_i_go_to_change_an_attachment
    and_i_go_to_add_an_attachment
    and_i_select_a_file_to_upload
    and_i_save_the_file_attachment
    then_i_can_see_the_attachment
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition
    document_type = build(:document_type, :with_body)
    @edition = create(:edition, document_type: document_type)
  end

  def given_there_is_an_edition_that_allows_featured_attachments
    document_type = build(:document_type, attachments: "featured")
    @edition = create(:edition, document_type: document_type)
  end

  def when_i_go_to_edit_the_edition
    visit document_path(@edition.document)
    click_on "Change Content"
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_go_to_insert_an_attachment
    find("markdown-toolbar details").click
    click_on "Attachment"
  end

  def and_i_go_to_change_an_attachment
    click_on "Change Attachments"
  end

  def and_i_go_to_add_an_attachment
    click_on "Upload file attachment"
  end

  def and_i_select_a_file_to_upload
    @attachment_filename = "13kb-1-page-attachment.pdf"
    @title = "A title"

    stub_asset_manager_receives_an_asset(filename: @attachment_filename)
    stub_publishing_api_put_content(@edition.content_id, {})

    find('form input[type="file"]').set(Rails.root.join(file_fixture(@attachment_filename)))
    fill_in "title", with: @title
  end

  def and_i_upload_the_file_attachment
    click_on "Upload"
  end

  def and_i_save_the_file_attachment
    click_on "Save and continue"
  end

  def then_i_can_see_the_attachment
    @metadata = "PDF, 13 KB, 1 page"

    within(".gem-c-attachment") do
      expect(page).to have_content(@title)
      expect(page).to have_content(@metadata)
    end
  end

  def and_i_can_see_an_action_to_preview_the_attachment
    within(".gem-c-attachment-link") do
      expect(page).to have_content(@title)
      expect(page).to have_content(@metadata)
    end
  end

  def and_i_see_the_timeline_entry
    visit document_path(@edition.document)
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.file_attachment_uploaded")
  end
end
