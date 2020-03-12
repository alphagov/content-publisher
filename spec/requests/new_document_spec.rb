RSpec.describe "New Document" do
  describe "GET /documents/show" do
    it "shows the root document type selection when no selection has been made" do
      get new_document_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_content(I18n.t("document_type_selections.root.label"))
    end

    it "shows the page for the selected document type" do
      get new_document_path, params: { type: "news" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_content(I18n.t("document_type_selections.news.label"))
    end

    it "returns a 404 when the requested document type selection doesn't exist", realistic_error_responses: true do
      get new_document_path, params: { type: "foo" }
      expect(response.status).to eq(404)
    end
  end

  describe "POST /documents/select" do
    it "redirects to document edit content when a content publisher managed document type is selected" do
      post new_document_path, params: { type: "news", selected_option_id: "news_story" }

      expect(response).to redirect_to(content_path(Document.last))
      follow_redirect!
      expect(response.body).to have_content("news story")
    end

    it "redirects when a document type managed elsewhere is selected" do
      post new_document_path, params: { type: "root", selected_option_id: "not_sure" }

      expect(response).to redirect_to(guidance_url)
    end

    it "asks the user to refine their selection when the document type has subtypes" do
      post new_document_path, params: { type: "root", selected_option_id: "news" }

      expect(response).to redirect_to(new_document_path(type: "news"))
      follow_redirect!
      expect(response.body).to have_content(I18n.t("document_type_selections.news_story.label"))
    end

    it "returns an unprocessable response with an issue when a document type isn't selected" do
      post new_document_path, params: { type: "news" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to have_content(
        I18n.t("requirements.document_type_selection.not_selected.form_message"),
      )
    end

    it "returns a 404 when the requested selected document type doesn't exist", realistic_error_responses: true do
      post new_document_path, params: { type: "foo", selected_option_id: "foo" }
      expect(response.status).to eq(404)
    end
  end
end
