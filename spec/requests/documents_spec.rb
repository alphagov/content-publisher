# frozen_string_literal: true

RSpec.describe "Documents" do
  it_behaves_like "requests that assert edition state",
                  "modifying a non editable edition",
                  routes: { document_path: %i[patch delete],
                            edit_document_path: %i[get],
                            delete_draft_path: %i[get],
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

    context "when the user has an organisation" do
      let(:organisation_content_id) { SecureRandom.uuid }
      let(:user) { create(:user, organisation_content_id: organisation_content_id) }
      before { login_as(user) }

      it "redirects to filter by the users organisation" do
        get documents_path
        expect(response).to redirect_to(
          documents_path(organisation: organisation_content_id),
        )
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

  describe "GET /documents/:document/edit" do
    it "returns successfully" do
      edition = create(:edition)
      get edit_document_path(edition.document)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /documents/:document" do
    before { stub_any_publishing_api_put_content }

    it "redirects to document summary" do
      edition = create(:edition)
      patch document_path(edition.document),
            params: { revision: { title: "My title" } }

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to include("My title")
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      edition = create(:edition, title: "Valid title")
      patch document_path(edition.document),
            params: { revision: { title: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to include(I18n.t!("requirements.title.blank.form_message"))
    end
  end

  describe "GET /documents/:document/delete-draft" do
    it "redirects to document summary with a confirmation prompt" do
      edition = create(:edition)
      get delete_draft_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to include(I18n.t!("documents.show.flashes.delete_draft"))
    end
  end

  describe "DELETE /documents/:document" do
    let(:edition) { create(:edition) }

    it "redirects to document index on success" do
      stub_publishing_api_unreserve_path(edition.base_path)
      stub_publishing_api_discard_draft(edition.content_id)

      delete document_path(edition.document)
      expect(response).to redirect_to(documents_path)
    end

    it "redirects to document summary when there is an API error" do
      stub_publishing_api_isnt_available

      delete document_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to include(I18n.t!("documents.show.flashes.delete_draft_error.title"))
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
