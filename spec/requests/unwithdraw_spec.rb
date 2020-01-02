# frozen_string_literal: true

RSpec.describe "Unwithdraw" do
  let(:managing_editor) { create(:user, managing_editor: true) }

  it_behaves_like "requests that assert edition state",
                  "unwithdrawing a non withdrawn edition",
                  routes: { unwithdraw_path: %i[get post] } do
    before { login_as(managing_editor) }
    let(:edition) { create(:edition, :published) }
  end

  describe "POST /documents/:document/unwithdraw" do
    let(:withdrawn_edition) { create(:edition, :withdrawn) }

    it "unwithdraws the edition" do
      stub_publishing_api_republish(withdrawn_edition.content_id, {})
      login_as(managing_editor)

      post unwithdraw_path(withdrawn_edition.document)

      expect(response).to redirect_to(document_path(withdrawn_edition.document))
    end

    it "returns an error when publishing-api is down" do
      stub_publishing_api_isnt_available
      login_as(managing_editor)

      post unwithdraw_path(withdrawn_edition.document)
      follow_redirect!

      expect(response.body).to include(I18n.t!("withdraw.new.flashes.publishing_api_error.title"))
    end

    it "prevents users without managing_editor permission from unwithdrawing the edition" do
      post unwithdraw_path(withdrawn_edition.document)

      expect(response.body).to include(I18n.t!("unwithdraw.no_managing_editor_permission.title"))
      expect(response).to have_http_status(:forbidden)
    end

    context "when the edition is in history mode" do
      let(:withdrawn_history_mode_edition) { create(:edition, :withdrawn, :political, government: past_government) }

      it "lets users holding manage_live_history_mode permission unwithdraw the edition" do
        stub_publishing_api_republish(withdrawn_history_mode_edition.content_id, {})
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)

        post unwithdraw_path(withdrawn_history_mode_edition.document)

        expect(response).to redirect_to(document_path(withdrawn_history_mode_edition.document))
      end

      it "prevents users without manage_live_history_mode permission from unwithdrawing the edition" do
        login_as(managing_editor)

        post unwithdraw_path(withdrawn_history_mode_edition.document)

        expect(response.body).to include(I18n.t!("missing_permissions.update_history_mode.title", title: withdrawn_history_mode_edition.title))
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /documents/:document/unwithdraw" do
    let(:withdrawn_edition) { create(:edition, :withdrawn) }

    it "fetches unwithdraw page" do
      login_as(managing_editor)

      get unwithdraw_path(withdrawn_edition.document)

      expect(response.body).to include(I18n.t!("unwithdraw.confirm.title", title: withdrawn_edition.title_or_fallback))
    end

    it "redirects to document summary when the edition is in the wrong state" do
      published_edition = create(:edition, :published)
      login_as(managing_editor)

      get unwithdraw_path(published_edition.document)

      expect(response).to redirect_to(document_path(published_edition.document))
    end

    it "prevents users without managing_editor permission from accessing unwithdraw page" do
      get unwithdraw_path(withdrawn_edition.document)

      expect(response.body).to include(I18n.t!("unwithdraw.no_managing_editor_permission.title"))
      expect(response).to have_http_status(:forbidden)
    end

    context "when the edition is in history mode" do
      let(:withdrawn_history_mode_edition) { create(:edition, :withdrawn, :political, government: past_government) }

      it "lets managing_editors holding manage_live_history_mode permission to access unwithdraw page" do
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)

        get unwithdraw_path(withdrawn_history_mode_edition.document)

        expect(response.body).to include(I18n.t!("unwithdraw.confirm.title", title: withdrawn_history_mode_edition.title_or_fallback))
      end

      it "prevents users without manage_live_history_mode permission from accessing unwithdraw page" do
        login_as(managing_editor)

        get unwithdraw_path(withdrawn_history_mode_edition.document)

        expect(response.body).to include(I18n.t!("missing_permissions.update_history_mode.title", title: withdrawn_history_mode_edition.title))
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
