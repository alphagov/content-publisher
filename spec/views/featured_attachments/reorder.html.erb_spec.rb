RSpec.describe "featured_attachments/reorder.html.erb" do
  it "shows file attachments and metadata that exist on the edition" do
    file_attachment_revision = create(:file_attachment_revision,
                                      unique_reference: SecureRandom.uuid)
    edition = create(:edition,
                     document_type: build(:document_type, attachments: "featured"),
                     file_attachment_revisions: [file_attachment_revision])
    assign(:edition, edition)

    render
    expect(rendered)
      .to have_content(file_attachment_revision.title)
      .and have_content(file_attachment_revision.unique_reference)
  end
end
