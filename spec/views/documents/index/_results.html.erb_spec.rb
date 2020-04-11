RSpec.describe "documents/index/_results" do
  describe "Results list" do
    it "shows a fallback for untitled documents" do
      edition = create(:edition, title: nil)
      assign(:editions, Kaminari.paginate_array([edition]).page)
      assign(:sort, "")
      assign(:filter_params, {})
      render
      expect(rendered).to include(I18n.t!("documents.untitled_document"))
    end
  end
end
