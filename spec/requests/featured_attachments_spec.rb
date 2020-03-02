RSpec.describe "Featured Attachments" do
  it_behaves_like "requests that assert edition state",
                  "accessing featured attachments for a non editable edition",
                  routes: { featured_attachments_path: %i[get] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents/:document/attachments" do
    it "returns successfully" do
      edition = create(:edition)
      get featured_attachments_path(edition.document)
      expect(response).to have_http_status(:ok)
    end
  end
end
