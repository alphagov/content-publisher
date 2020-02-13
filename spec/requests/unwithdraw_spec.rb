RSpec.describe "Unwithdraw" do
  let(:managing_editor) { create(:user, managing_editor: true) }

  it_behaves_like "requests that assert edition state",
                  "unwithdrawing a non withdrawn edition",
                  routes: { unwithdraw_path: %i[get post] } do
    before { login_as(managing_editor) }

    let(:edition) { create(:edition, :published) }
  end

  describe "POST /documents/:document/unwithdraw" do
    let(:edition) { create(:edition, :withdrawn) }

    before { stub_publishing_api_republish(edition.content_id, {}) }

    context "when logged in as a managing editor" do
      let(:managing_editor) { create(:user, managing_editor: true) }

      before { login_as(managing_editor) }

      it "redirects to document summary" do
        post unwithdraw_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end

      it "redirects to document summary with an error when Publishing API is down" do
        stub_publishing_api_isnt_available

        post unwithdraw_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
        follow_redirect!
        expect(response.body).to have_content(
          I18n.t!("documents.show.flashes.unwithdraw_error.title"),
        )
      end
    end

    context "when not logged in as a managing editor" do
      it "returns a forbidden response" do
        post unwithdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body)
          .to have_content(I18n.t!("unwithdraw.no_managing_editor_permission.title"))
      end
    end

    context "when the edition is in history mode" do
      let(:edition) do
        create(:edition, :withdrawn, :political, government: past_government)
      end

      it "allows a managing editor with the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)

        post unwithdraw_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end

      it "forbids a managing editor without the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: false)
        login_as(user)
        post unwithdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("missing_permissions.update_history_mode.title", title: edition.title),
        )
      end

      it "forbids a user who isn't a managing editor, even with the manage_live_history_mode permission" do
        user = create(:user, manage_live_history_mode: true)
        login_as(user)
        post unwithdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("unwithdraw.no_managing_editor_permission.title"),
        )
      end
    end
  end

  describe "GET /documents/:document/unwithdraw" do
    let(:edition) { create(:edition, :withdrawn) }

    context "when logged in as a managing editor" do
      let(:managing_editor) { create(:user, managing_editor: true) }

      before { login_as(managing_editor) }

      it "returns successfully" do
        get unwithdraw_path(edition.document)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in as a managing editor" do
      it "returns a forbidden response" do
        get unwithdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("unwithdraw.no_managing_editor_permission.title"),
        )
      end
    end

    context "when the edition is in history mode" do
      let(:edition) do
        create(:edition, :withdrawn, :political, government: past_government)
      end

      it "allows a managing editor with the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)
        get unwithdraw_path(edition.document)
        expect(response).to have_http_status(:ok)
      end

      it "forbids a managing editor without the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: false)
        login_as(user)
        get unwithdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("missing_permissions.update_history_mode.title", title: edition.title),
        )
      end

      it "forbids a user who isn't a managing editor, even with the manage_live_history_mode permission" do
        user = create(:user, manage_live_history_mode: true)
        login_as(user)
        get unwithdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("unwithdraw.no_managing_editor_permission.title"),
        )
      end
    end
  end
end
