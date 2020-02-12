RSpec.describe "Editions" do
  it_behaves_like "requests that assert edition state",
                  "discarding a non editable edition",
                  routes: {
                    destroy_draft_path: %i[delete],
                    confirm_delete_draft_path: %i[get],
                  } do
    let(:edition) { create(:edition, :published) }
  end

  it_behaves_like "requests that assert edition state",
                  "creating a new edition on a non live edition",
                  routes: { create_edition_path: %i[post] } do
    let(:edition) { create(:edition) }
  end

  describe "POST /document/:document/editions" do
    it "redirects to edit document" do
      edition = create(:edition, :published)
      stub_publishing_api_put_content(edition.content_id, {})

      post create_edition_path(edition.document)
      expect(response).to redirect_to(content_path(edition.document))
    end

    context "when the edition is in history mode" do
      let(:edition) { create(:edition, :published, :political, government: past_government) }

      it "lets users holding the manage_live_history_mode permisssion create a new edition" do
        user = create(:user, manage_live_history_mode: true)
        login_as(user)
        stub_publishing_api_put_content(edition.content_id, {})

        post create_edition_path(edition.document)
        expect(response).to redirect_to(content_path(edition.document))
      end

      it "prevents users without the permission creating a new edition" do
        post create_edition_path(edition.document)

        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("missing_permissions.update_history_mode.title",
                  title: edition.title),
        )
      end
    end
  end

  describe "GET /documents/:document/delete-draft" do
    it "returns successfully" do
      edition = create(:edition)
      get confirm_delete_draft_path(edition.document)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /documents/:document/draft" do
    let(:edition) { create(:edition) }

    it "redirects to document index on success" do
      stub_publishing_api_unreserve_path(edition.base_path)
      stub_publishing_api_discard_draft(edition.content_id)

      delete destroy_draft_path(edition.document)
      expect(response).to redirect_to(documents_path)
    end

    it "redirects to document summary when there is an API error" do
      stub_publishing_api_isnt_available

      delete destroy_draft_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_content(I18n.t!("documents.show.flashes.delete_draft_error.title"))
    end
  end
end
