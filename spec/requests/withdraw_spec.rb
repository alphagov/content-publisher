# frozen_string_literal: true

RSpec.describe "Withdraw" do
  let(:managing_editor) { create(:user, managing_editor: true) }

  it_behaves_like "requests that assert edition state",
                  "withdrawing a draft edition",
                  routes: { withdraw_path: %i[get post] } do
    before { login_as(managing_editor) }
    let(:edition) { create(:edition) }
  end

  describe "POST /documents/:document/withdraw" do
    let(:edition) { create(:edition, :published) }
    let(:public_explanation) { SecureRandom.alphanumeric(10) }

    before do
      stub_publishing_api_unpublish(edition.content_id, body: {})
    end

    context "when logged in as a managing editor" do
      let(:managing_editor) { create(:user, managing_editor: true) }
      before { login_as(managing_editor) }

      it "allows withdrawing an edtiion" do
        post withdraw_path(edition.document),
             params: { public_explanation: public_explanation }
        expect(response).to redirect_to(document_path(edition.document))
      end

      it "returns a service unavailable response with error when Publishing API is unavailable" do
        stub_publishing_api_isnt_available

        post withdraw_path(edition.document),
             params: { public_explanation: public_explanation }
        expect(response).to have_http_status(:service_unavailable)
        expect(response.body).to have_content(
          I18n.t!("withdraw.new.flashes.publishing_api_error.title"),
        )
      end

      it "returns issues and an unprocessable response when there are requirement issues" do
        post withdraw_path(edition.document),
             params: { public_explanation: "" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to have_content(
          I18n.t!("requirements.public_explanation.blank.form_message"),
        )
      end
    end

    context "when not logged in as a managing editor" do
      it "returns a forbidden response" do
        edition = create(:edition, :published)
        post withdraw_path(edition.document),
             params: { public_explanation: public_explanation }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("withdraw.no_managing_editor_permission.title"),
        )
      end
    end

    context "when the edition is in history mode" do
      let(:edition) do
        create(:edition, :published, :political, government: past_government)
      end

      it "allows a managing editor with the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)
        post withdraw_path(edition.document),
             params: { public_explanation: public_explanation }
        expect(response).to redirect_to(document_path(edition.document))
      end

      it "forbids a managing editor without the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: false)
        login_as(user)
        post withdraw_path(edition.document),
             params: { public_explanation: public_explanation }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("missing_permissions.update_history_mode.title", title: edition.title),
        )
      end

      it "forbids a user who isn't a managing editor, even with the manage_live_history_mode permission" do
        user = create(:user, manage_live_history_mode: true)
        login_as(user)
        post withdraw_path(edition.document),
             params: { public_explanation: public_explanation }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("withdraw.no_managing_editor_permission.title"),
        )
      end
    end
  end

  describe "GET /documents/:document/withdraw" do
    context "when logged in as a managing editor" do
      let(:managing_editor) { create(:user, managing_editor: true) }
      before { login_as(managing_editor) }

      it "allows withdrawing a published edtiion" do
        edition = create(:edition, :published)
        get withdraw_path(edition.document)
        expect(response).to have_http_status(:ok)
      end

      it "allows withdrawing a published but needs 2i edtiion" do
        edition = create(:edition, :published, state: :published_but_needs_2i)
        get withdraw_path(edition.document)
        expect(response).to have_http_status(:ok)
      end

      it "allows re-withdrawing a withdrawn edtiion" do
        edition = create(:edition, :withdrawn)
        get withdraw_path(edition.document)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in as a managing editor" do
      it "returns a forbidden response" do
        edition = create(:edition, :published)
        get withdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("withdraw.no_managing_editor_permission.title"),
        )
      end
    end

    context "when the edition is in history mode" do
      let(:edition) do
        create(:edition, :published, :political, government: past_government)
      end

      it "allows a managing editor with the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)
        get withdraw_path(edition.document)
        expect(response).to have_http_status(:ok)
      end

      it "forbids a managing editor without the manage_live_history_mode permission" do
        user = create(:user, managing_editor: true, manage_live_history_mode: false)
        login_as(user)
        get withdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("missing_permissions.update_history_mode.title", title: edition.title),
        )
      end

      it "forbids a user who isn't a managing editor, even with the manage_live_history_mode permission" do
        user = create(:user, manage_live_history_mode: true)
        login_as(user)
        get withdraw_path(edition.document)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to have_content(
          I18n.t!("withdraw.no_managing_editor_permission.title"),
        )
      end
    end
  end
end
