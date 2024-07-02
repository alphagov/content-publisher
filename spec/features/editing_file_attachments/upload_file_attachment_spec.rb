RSpec.feature "Upload file attachment", :js do
  scenario "inline attachment" do
    given_there_is_an_edition
    when_i_go_to_edit_the_edition
    and_i_go_to_insert_an_attachment
    and_i_select_a_file_to_upload
    and_i_upload_the_file_attachment
    then_i_can_insert_the_attachment
    and_i_see_the_timeline_entry
  end

  scenario "featured attachment" do
    given_there_is_an_edition_that_allows_featured_attachments
    when_i_visit_the_summary_page
    and_i_go_to_change_an_attachment
    and_i_go_to_add_an_attachment
    and_i_select_a_file_to_upload
    and_i_enter_attachment_metadata
    then_i_can_see_the_attachment
    and_i_see_the_timeline_entry
  end

  def given_there_is_an_edition
    document_type = build(:document_type, :with_body)
    @edition = create(:edition, document_type:)
  end

  def given_there_is_an_edition_that_allows_featured_attachments
    document_type = build(:document_type, attachments: "featured")
    @edition = create(:edition, document_type:)
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

  def and_i_enter_attachment_metadata
    click_on "Save and continue"
    unique_ref = "REF"
    isbn = "9788700631625"
    paper_number = "CP 1234"
    @metadata = "Ref: ISBN #{isbn}, #{unique_ref}"

    fill_in "file_attachment[unique_reference]", with: unique_ref
    fill_in "file_attachment[isbn]", with: isbn
    choose I18n.t!("file_attachments.edit.official_document.options.command_paper.label")
    fill_in "file_attachment[command_paper_number]", with: paper_number

    stub_asset_manager_updates_any_asset
    click_on "Save"
  end

  def then_i_can_see_the_attachment
    file_metadata = "PDF, 13 KB, 1 page"

    within(".gem-c-attachment") do
      expect(page).to have_content(@title)
      expect(page).to have_content(file_metadata)
      expect(page).to have_content(@metadata)
    end
  end

  def then_i_can_insert_the_attachment
    file_metadata = "PDF, 13 KB, 1 page"

    within(".gem-c-attachment") do
      expect(page).to have_content(@title)
      expect(page).to have_content(file_metadata)
    end

    within(".gem-c-attachment-link") do
      expect(page).to have_content(@title)
      expect(page).to have_content(file_metadata)
    end
  end

  def and_i_see_the_timeline_entry
    visit document_path(@edition.document)
    click_on "Document history"
    expect(page).to have_content I18n.t!("documents.history.entry_types.file_attachment_uploaded")
  end
end
