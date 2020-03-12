RSpec.feature "Download a file attachment" do
  scenario "featured" do
    given_there_is_an_edition_with_featured_attachments
    when_i_visit_the_attachments_index_page
    and_i_download_the_attachment
    then_the_attachment_should_download
  end

  scenario "inline" do
    given_there_is_an_edition_with_attachments
    when_i_click_to_insert_an_attachment
    and_i_download_the_attachment
    then_the_attachment_should_download
  end

  def given_there_is_an_edition_with_featured_attachments
    document_type = build(:document_type, attachments: "featured")
    @attachment_revision = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type: document_type,
                      file_attachment_revisions: [@attachment_revision])
  end

  def given_there_is_an_edition_with_attachments
    @attachment_revision = create(:file_attachment_revision)

    @edition = create(:edition,
                      document_type: build(:document_type, :with_body),
                      file_attachment_revisions: [@attachment_revision])
  end

  def when_i_visit_the_attachments_index_page
    visit featured_attachments_path(@edition.document)
  end

  def when_i_click_to_insert_an_attachment
    visit content_path(@edition.document)
    find("markdown-toolbar details").click
    click_on "Attachment"
    expect(page).to have_content("74 Bytes")
  end

  def and_i_download_the_attachment
    click_on("Download")
  end

  def then_the_attachment_should_download
    expected = "attachment; " +
      "filename=\"#{@attachment_revision.filename}\"; " +
      "filename*=UTF-8\'\'#{@attachment_revision.filename}"

    expect(page.response_headers["Content-Disposition"]).to eq(expected)
  end
end
