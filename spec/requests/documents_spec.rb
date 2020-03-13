RSpec.describe "Documents" do
  it_behaves_like "requests that assert edition state",
                  "modifying a non editable edition",
                  routes: { content_path: %i[patch get],
                            generate_path_path: %i[get] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents" do
    before { stub_publishing_api_has_linkables([], document_type: "organisation") }

    context "when filter parameters are provided" do
      it "returns successfully" do
        get documents_path(organisation: "")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user doesn't have an organisation" do
      let(:user) { create(:user, organisation_content_id: nil) }

      before { login_as(user) }

      it "returns successfully" do
        get documents_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /documents/:document/generate-path" do
    it "returns a text response of a path" do
      edition = create(:edition, title: "A title")
      prefix = edition.document_type.path_prefix
      get generate_path_path(edition.document, title: "A title")

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      expect(response.body).to match("#{prefix}/a-title")
    end
  end
end
