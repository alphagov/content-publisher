# frozen_string_literal: true

RSpec.describe "Editions" do
  describe "POST /document/:document/editions" do
    it "creates a new edition" do
      edition = create(:edition, :published)
      stub_publishing_api_put_content(edition.content_id, {})

      expect { post create_edition_path(edition.document) }
        .to change { Edition.where(document_id: edition.document.id).count }.by(1)
    end

    context "when the edition is in history mode" do
      let(:edition) { create(:edition, :published, :political, government: past_government) }

      it "lets users holding the manage_live_history_mode permisssion create a new edition" do
        user = create(:user, manage_live_history_mode: true)
        login_as(user)
        stub_publishing_api_put_content(edition.content_id, {})

        expect { post create_edition_path(edition.document) }
          .to change { Edition.where(document_id: edition.document.id).count }.by(1)
      end

      it "prevents users without the permission creating a new edition" do
        post create_edition_path(edition.document)

        expect(response.body).to include(I18n.t!("missing_permissions.update_history_mode.title", title: edition.title))
        expect(response.status).to eq(403)
      end
    end
  end
end
