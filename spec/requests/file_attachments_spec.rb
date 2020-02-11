RSpec.describe "File Attachments" do
  it_behaves_like "requests that assert edition state",
                  "accessing file attachments for a non editable edition",
                  routes: { file_attachments_path: %i[get post] } do
    let(:edition) { create(:edition, :published) }
  end

  it_behaves_like "requests that assert edition state",
                  "accessing a single file attachments for a non editable edition",
                  routes: { file_attachment_path: %i[get delete],
                            edit_file_attachment_path: %i[get patch],
                            preview_file_attachment_path: %i[get] } do
    let(:edition) { create(:edition, :published) }
    let(:route_params) { [edition.document, "file_attachment_id"] }
  end

  it_behaves_like "requests that return status",
                  "when a file attachment revision belongs to a different edition",
                  status: :not_found,
                  routes: { file_attachment_path: %i[get delete],
                            edit_file_attachment_path: %i[get patch],
                            preview_file_attachment_path: %i[get] } do
    let(:edition) { create(:edition) }
    let(:file_attachment_revision) { create(:file_attachment_revision) }
    let(:route_params) { [edition.document, file_attachment_revision] }
  end

  describe "GET /documents/:document/file-attachments/:file_attachment_id" do
    it "shows the file attachment when it exists on the edition" do
      file_attachment_revision = create(:file_attachment_revision)
      edition = create(:edition,
                       file_attachment_revisions: [file_attachment_revision])

      get file_attachment_path(edition.document,
                               file_attachment_revision.file_attachment_id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_content(file_attachment_revision.filename)
    end
  end

  describe "GET /documents/:document/file-attachments/:file_attachment_id/preview" do
    it "redirects to the file when it's available" do
      file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
      asset = file_attachment_revision.asset
      stub_asset_manager_has_an_asset(asset.asset_manager_id, state: "uploaded")

      edition = create(:edition,
                       file_attachment_revisions: [file_attachment_revision])

      get preview_file_attachment_path(edition.document,
                                       file_attachment_revision.file_attachment_id)

      expect(response).to redirect_to(/#{asset.file_url}\?token=.*/)
    end

    it "returns an unavailable status when the asset isn't uploaded to asset manager" do
      file_attachment_revision = create(:file_attachment_revision)

      edition = create(:edition,
                       file_attachment_revisions: [file_attachment_revision])

      stub_asset_manager_receives_an_asset
      get preview_file_attachment_path(edition.document,
                                       file_attachment_revision.file_attachment_id)

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body)
        .to have_content(I18n.t!("file_attachments.preview_pending.title"))
    end

    it "returns an unavailable status when asset manager is down" do
      file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)

      edition = create(:edition,
                       file_attachment_revisions: [file_attachment_revision])

      stub_asset_manager_isnt_available
      get preview_file_attachment_path(edition.document,
                                       file_attachment_revision.file_attachment_id)

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body)
        .to have_content(I18n.t!("file_attachments.preview_pending.title"))
    end
  end

  describe "POST /documents/:document/file-attachments" do
    let(:edition) { create(:edition) }

    before { stub_publishing_api_put_content(edition.content_id, {}) }

    it "redirects to edit view when file attachment is created successfully" do
      stub_asset_manager_receives_an_asset(filename: "text-file-74bytes.txt")

      file = fixture_file_upload("files/text-file-74bytes.txt")
      post file_attachments_path(edition.document),
           params: { file: file, title: "File" }

      file_attachment = FileAttachment.last
      expect(response)
        .to redirect_to(file_attachment_path(edition.document, file_attachment))
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      file = fixture_file_upload("files/bad_file.rb")
      post file_attachments_path(edition.document),
           params: { file: file, title: "File" }

      expect(response).to have_http_status(:unprocessable_entity)
      issue = I18n.t!("requirements.file_attachment_upload.unsupported_type.form_message")
      expect(response.body).to have_content(issue)
    end
  end

  describe "DELETE /documents/:document/file-attachments/:file_attachment_id" do
    before { stub_publishing_api_put_content(edition.content_id, {}) }

    let(:file_attachment_revision) { create(:file_attachment_revision) }
    let(:edition) do
      create(:edition, file_attachment_revisions: [file_attachment_revision])
    end

    it "redirects to the file attachment index" do
      delete file_attachment_path(edition.document,
                                  file_attachment_revision.file_attachment_id)

      expect(response).to redirect_to(file_attachments_path(edition.document))
    end
  end

  describe "GET /documents/:document/file-attachments/:file_attachment_id/edit" do
    let(:file_attachment_revision) { create(:file_attachment_revision) }

    it "shows the file attachment when it exists on the edition" do
      file_attachment_revision = create(:file_attachment_revision)
      edition = create(:edition,
                       file_attachment_revisions: [file_attachment_revision])

      get edit_file_attachment_path(edition.document,
                                    file_attachment_revision.file_attachment_id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_content(file_attachment_revision.filename)
    end
  end

  describe "PATCH /documents/:document/file-attachments/:file_attachment_id/edit" do
    before do
      stub_publishing_api_put_content(edition.content_id, {})
      stub_asset_manager_update_asset(file_attachment_revision.asset.asset_manager_id)
    end

    let(:file_attachment_revision) { create(:file_attachment_revision, :on_asset_manager) }
    let(:file_attachment_id) { file_attachment_revision.file_attachment_id }
    let(:edition) do
      create(:edition, file_attachment_revisions: [file_attachment_revision])
    end

    it "redirects to the file attachments index with a flash message when changed" do
      patch edit_file_attachment_path(edition.document, file_attachment_id),
            params: { file_attachment: { title: "New title" } }

      expect(response).to redirect_to(file_attachments_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content(
        I18n.t!("file_attachments.edit.flashes.update_confirmation"),
      )
    end

    it "redirects to the file attachments index without a flash message when unchanged" do
      patch edit_file_attachment_path(edition.document, file_attachment_id),
            params: { file_attachment: { title: file_attachment_revision.title } }

      expect(response).to redirect_to(file_attachments_path(edition.document))
      follow_redirect!
      expect(response.body).not_to have_content(
        I18n.t!("file_attachments.edit.flashes.update_confirmation"),
      )
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      patch edit_file_attachment_path(edition.document, file_attachment_id),
            params: { file_attachment: { title: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to have_content(
        I18n.t!("requirements.file_attachment_title.blank.form_message"),
      )
    end
  end
end
