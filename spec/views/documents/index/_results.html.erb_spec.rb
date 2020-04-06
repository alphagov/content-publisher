RSpec.describe "documents/index/results.html.erb" do
  describe "Results list" do
    it "shows a fallback for untitled documents" do
      edition = create(:edition, title: nil)
      assign(:editions, Kaminari.paginate_array([edition]).page)
      assign(:sort, "")
      assign(:filter_params, {})
      render partial: self.class.top_level_description
      expect(rendered).to include(I18n.t!("documents.untitled_document"))
    end
  end
end
