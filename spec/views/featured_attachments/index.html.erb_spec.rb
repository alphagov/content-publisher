RSpec.describe "featured_attachments/index" do
  it "shows file attachments that exist on the edition" do
    file_attachment_revision = create(:file_attachment_revision)
    edition = create(:edition,
                     file_attachment_revisions: [file_attachment_revision])
    assign(:edition, edition)
    render
    expect(rendered).to have_content(file_attachment_revision.title)
  end

  it "shows a message when there aren't any attachments" do
    assign(:edition, create(:edition))
    render
    expect(rendered).to have_content(I18n.t!("featured_attachments.index.no_attachments"))
  end

  it "shows a reorder action for multiple attachments" do
    file_attachment_revisions = create_list(:file_attachment_revision, 2)
    edition = create(:edition,
                     file_attachment_revisions:)
    assign(:edition, edition)
    render
    expect(rendered).to have_content("Reorder attachments")
  end

  it "doesn't show a reorder action for a single attachment" do
    file_attachment_revision = create(:file_attachment_revision)
    edition = create(:edition,
                     file_attachment_revisions: [file_attachment_revision])
    assign(:edition, edition)
    render
    expect(rendered).not_to have_content("Reorder attachments")
  end
end
