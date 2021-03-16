RSpec.describe "featured_attachments/featured_attachment" do
  describe "official document metadata" do
    let(:edition) do
      create(:edition, document_type: build(:document_type, attachments: "featured"))
    end

    def render_with_attachment(attributes)
      attachment = create(:file_attachment_revision, attributes)

      render partial: self.class.top_level_description,
             locals: { edition: edition, attachment: attachment }
    end

    it "renders a command paper with its number" do
      render_with_attachment(official_document_type: "command_paper", paper_number: "123")
      expect(rendered).to have_content("Ref: 123")
    end

    it "renders an act paper with its number" do
      render_with_attachment(official_document_type: "act_paper", paper_number: "123")
      expect(rendered).to have_content("Ref: HC 123")
    end

    it "renders an unnumbered command paper" do
      render_with_attachment(official_document_type: "command_paper")
      expect(rendered).to have_content("Unnumbered command paper")
    end

    it "renders an unnumbered act paper" do
      render_with_attachment(official_document_type: "act_paper")
      expect(rendered).to have_content("Unnumbered act paper")
    end
  end
end
