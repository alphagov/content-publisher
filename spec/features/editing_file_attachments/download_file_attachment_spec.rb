RSpec.feature "Download a file attachment" do
  scenario do
    given_there_is_an_edition_with_featured_attachments
    when_i_visit_the_attachments_index_page
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

  def when_i_visit_the_attachments_index_page
    visit featured_attachments_path(@edition.document)
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
