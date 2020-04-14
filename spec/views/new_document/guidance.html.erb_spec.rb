RSpec.describe "new_document/guidance" do
  it "renders the associated Markdown content" do
    render
    expect(rendered).to have_selector(".gem-c-govspeak")
  end
end
