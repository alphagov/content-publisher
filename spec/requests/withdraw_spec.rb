# frozen_string_literal: true

RSpec.describe "Withdraw" do
  let(:edition) { create(:edition, :published, :political, :past_government) }

  describe "POST /documents/:document/withdraw" do
    context "when the edition is in history mode" do
      it "lets users holding manage_live_history_mode permisssion withdraw the edition" do
        stub_publishing_api_unpublish(edition.content_id, body: {})
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)

        post withdraw_path(edition.document), params: { public_explanation: "Just cos" }
        follow_redirect!

        withdrawal = edition.reload.status.details
        expect(response.body).to include(
          I18n.t!("documents.show.withdrawn.title",
                  document_type: edition.document_type.label.downcase,
                  withdrawn_date: withdrawal.created_at.strftime("%-d %B %Y")),
        )
      end

      it "prevents users without manage_live_history_mode permisssion to withdraw the edition" do
        user = create(:user, managing_editor: true)
        login_as(user)

        post withdraw_path(edition.document), params: { public_explanation: "Just cos" }

        expect(response.body).to include(I18n.t!("missing_permissions.update_history_mode.title", title: edition.title))
        expect(response.status).to eq(403)
      end
    end
  end

  describe "GET /documents/:document/withdraw" do
    context "when the edition is in history mode" do
      it "lets users holding manage_live_history_mode permisssion to access withdraw page" do
        stub_publishing_api_unpublish(edition.content_id, body: {})
        user = create(:user, managing_editor: true, manage_live_history_mode: true)
        login_as(user)

        get withdraw_path(edition.document)

        expect(response.body).to include(I18n.t!("withdraw.new.title", title: edition.title))
      end

      it "prevents users without manage_live_history_mode permisssion to access withdraw" do
        user = create(:user, managing_editor: true)
        login_as(user)

        get withdraw_path(edition.document)

        expect(response.body).to include(I18n.t!("missing_permissions.update_history_mode.title", title: edition.title))
        expect(response.status).to eq(403)
      end
    end
  end
end
