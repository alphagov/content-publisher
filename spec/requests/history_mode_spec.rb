RSpec.describe "History Mode" do
  it_behaves_like "requests that assert edition state",
                  "managing history mode on a non editable edition",
                  routes: { history_mode_path: %i[get patch] } do
    before { login_as(create(:user, managing_editor: true)) }

    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents/:document/history-mode" do
    it "returns successfully for a user with managing editor permission" do
      edition = create(:edition)
      login_as(create(:user, managing_editor: true))
      get history_mode_path(edition.document)
      expect(response).to have_http_status(:ok)
    end

    it "returns a forbidden status for user without managing editor permission" do
      edition = create(:edition)
      login_as(create(:user))
      get history_mode_path(edition.document)
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to have_content(
        I18n.t!("history_mode.non_managing_editor.title", title: edition.title),
      )
    end
  end

  describe "PATCH /documents/:document/history-mode" do
    it "redirects to document summary for a user with managing editor permission" do
      edition = create(:edition)
      stub_publishing_api_put_content(edition.content_id, {})
      login_as(create(:user, managing_editor: true))
      patch history_mode_path(edition.document), params: { "political" => "yes" }
      expect(response).to redirect_to(document_path(edition.document))
    end

    it "returns a forbidden status for user without managing editor permission" do
      edition = create(:edition)
      login_as(create(:user))
      patch history_mode_path(edition.document), params: { "political" => "yes" }
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to have_content(
        I18n.t!("history_mode.non_managing_editor.title", title: edition.title),
      )
    end
  end
end
