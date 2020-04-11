RSpec.describe "file_attachments/replace" do
  it "shows a 'Save' button by default" do
    assign(:edition, build(:edition))
    assign(:attachment, create(:file_attachment_revision))
    render
    expect(rendered).to have_button("Save")
  end

  context "when uploading and navigating back" do
    it "shows a 'Save and continue' button" do
      assign(:edition, build(:edition))
      assign(:attachment, create(:file_attachment_revision))

      render template: described_template,
             locals: { params: { wizard: "featured-attachment-upload" } }

      expect(rendered).to have_button("Save and continue")
    end
  end
end
