RSpec.describe "file_attachments/edit" do
  describe "official documents" do
    it "renders official document types" do
      assign(:edition, build(:edition))
      assign(:attachment, create(:file_attachment_revision))
      render

      types = %i[command_paper
                 unnumbered_command_paper
                 act_paper
                 unnumbered_act_paper
                 unofficial]

      types.each do |type|
        expect(rendered).to have_selector("input[@type='radio'][@value='#{type}']")
      end
    end
  end
end
