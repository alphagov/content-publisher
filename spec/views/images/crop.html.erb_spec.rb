RSpec.describe "images/crop.html.erb" do
  it "shows a 'Save' button with JS" do
    assign(:image_revision, create(:image_revision))
    assign(:edition, build(:edition))
    render
    expect(rendered).to have_button("Save")
  end

  it "shows a 'Continue' button without JS" do
    assign(:image_revision, create(:image_revision))
    assign(:edition, build(:edition))
    render
    expect(rendered).to have_selector(".app-no-js button", text: "Continue")
  end

  context "when the image has exact dimensions" do
    it "shows a 'Continue' button instead" do
      assign(:image_revision, create(:image_revision,
                                     width: Image::WIDTH,
                                     height: Image::HEIGHT))

      assign(:edition, build(:edition))
      render
      expect(rendered).to have_selector(".app-js-only button", text: "Continue")
    end
  end

  context "when uploading a new image" do
    it "shows a 'Save and continue' button" do
      assign(:image_revision, create(:image_revision))
      assign(:edition, build(:edition))
      render template: self.class.top_level_description,
             locals: { params: { wizard: "upload" } }
      expect(rendered).to have_button("Save and continue")
    end
  end
end
