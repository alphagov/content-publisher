RSpec.describe "Insert inline file attachment" do
  it "block snippet", js: true do
    given_there_is_an_edition_with_file_attachments
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_file_attachment
    and_i_choose_one_of_the_file_attachments
    and_i_click_on_insert_attachment
    then_i_see_the_attachment_snippet_is_inserted
  end

  it "link snippet", js: true do
    given_there_is_an_edition_with_file_attachments
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_file_attachment
    and_i_choose_one_of_the_file_attachments
    and_i_click_on_insert_attachment_as_link
    then_i_see_the_attachment_link_snippet_is_inserted
  end

  it "without javascript" do
    given_there_is_an_edition_with_file_attachments
    when_i_go_to_edit_the_edition
    and_i_click_to_insert_a_file_attachment
    and_i_choose_one_of_the_file_attachments
    then_i_see_the_attachment_markdown_snippet
    and_i_see_the_attachment_link_markdown_snippet
  end

  def given_there_is_an_edition_with_file_attachments
    @file_attachment_revision = create(:file_attachment_revision,
                                       :on_asset_manager,
                                       filename: "foo.pdf")
    @edition = create(:edition,
                      document_type: build(:document_type, :with_body),
                      file_attachment_revisions: [@file_attachment_revision])
  end

  def when_i_go_to_edit_the_edition
    visit content_path(@edition.document)
  end

  def and_i_click_to_insert_a_file_attachment
    within(".app-c-markdown-editor") do
      find("markdown-toolbar details").click
      click_on "Attachment"
    end
  end

  def and_i_choose_one_of_the_file_attachments
    click_on "Insert attachment"
  end

  def and_i_click_on_insert_attachment
    click_on "Insert attachment"
  end

  def and_i_click_on_insert_attachment_as_link
    click_on "Insert attachment as link"
  end

  def then_i_see_the_attachment_snippet_is_inserted
    expect(page).not_to have_selector(".gem-c-modal-dialogue") # wait for modal to close
    snippet = I18n.t("file_attachments.show.attachment_markdown",
                     filename: @file_attachment_revision.filename)
    expect(find("#body-field").value).to include snippet
  end

  def then_i_see_the_attachment_link_snippet_is_inserted
    expect(page).not_to have_selector(".gem-c-modal-dialogue") # wait for modal to close
    snippet = I18n.t("file_attachments.show.attachment_link_markdown",
                     filename: @file_attachment_revision.filename)
    expect(find("#body-field").value).to include snippet
  end

  def then_i_see_the_attachment_markdown_snippet
    snippet = I18n.t("file_attachments.show.attachment_markdown",
                     filename: @file_attachment_revision.filename)
    expect(page).to have_content(snippet)
  end

  def and_i_see_the_attachment_link_markdown_snippet
    snippet = I18n.t("file_attachments.show.attachment_link_markdown",
                     filename: @file_attachment_revision.filename)
    expect(page).to have_content(snippet)
  end
end
