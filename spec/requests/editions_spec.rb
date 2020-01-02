# frozen_string_literal: true

RSpec.describe "Editions" do
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
      expect(response).to redirect_to(edit_document_path(edition.document))
    end

    context "when the edition is in history mode" do
      let(:edition) { create(:edition, :published, :political, government: past_government) }

      it "lets users holding the manage_live_history_mode permisssion create a new edition" do
        user = create(:user, manage_live_history_mode: true)
        login_as(user)
        stub_publishing_api_put_content(edition.content_id, {})

        post create_edition_path(edition.document)
        expect(response).to redirect_to(edit_document_path(edition.document))
      end

      it "prevents users without the permission creating a new edition" do
        post create_edition_path(edition.document)

        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include(
          I18n.t!("missing_permissions.update_history_mode.title",
                  title: edition.title),
        )
      end
    end
  end
end
