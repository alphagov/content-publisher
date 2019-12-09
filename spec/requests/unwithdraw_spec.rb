# frozen_string_literal: true

RSpec.describe "Unwithdraw" do
  let(:edition) { create(:edition, :withdrawn, :political, :past_government) }

  describe "POST /documents/:document/unwithdraw" do
    context "when the edition is in history mode" do
      it "lets users holding manage_live_history_mode permisssion unwithdraw the edition" do
        stub_publishing_api_republish(edition.content_id, {})
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)

        post unwithdraw_path(edition.document)
        follow_redirect!

        expect(response.body).to include(I18n.t!("documents.history.entry_types.unwithdrawn"))
      end

      it "prevents users without manage_live_history_mode permisssion to unwithdraw the edition" do
        user = create(:user, managing_editor: true)
        login_as(user)

        post unwithdraw_path(edition.document)

        expect(response.body).to include(I18n.t!("missing_permissions.update_history_mode.title", title: edition.title))
        expect(response.status).to eq(403)
      end
    end
  end

  describe "GET /documents/:document/unwithdraw" do
    context "when the edition is in history mode" do
      it "lets users holding manage_live_history_mode permisssion to access unwithdraw page" do
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)

        get unwithdraw_path(edition.document)
        follow_redirect!

        expect(response.body).to include(I18n.t!("documents.show.unwithdraw.title"))
      end

      it "prevents users without manage_live_history_mode permisssion to access unwithdraw page" do
        user = create(:user, managing_editor: true)
        login_as(user)

        get unwithdraw_path(edition.document)

        expect(response.body).to include(I18n.t!("missing_permissions.update_history_mode.title", title: edition.title))
        expect(response.status).to eq(403)
      end
    end
  end
end
