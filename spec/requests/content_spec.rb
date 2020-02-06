# frozen_string_literal: true

RSpec.describe "Content" do
  it_behaves_like "requests that assert edition state",
                  "modifying a non editable edition",
                  routes: { content_path: %i[patch get] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents/:document/content" do
    it "returns successfully" do
      edition = create(:edition)
      get content_path(edition.document)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /documents/:document/content" do
    before { stub_any_publishing_api_put_content }

    it "redirects to document summary" do
      edition = create(:edition)
      patch content_path(edition.document), params: { summary: "My summary" }
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content("My summary")
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      edition = create(:edition, summary: "Valid summary")
      patch content_path(edition.document), params: { summary: "new\nline" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to have_content(I18n.t!("requirements.summary.multiline.form_message"))
    end
  end
end
