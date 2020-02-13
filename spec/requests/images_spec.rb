RSpec.describe "Images" do
  it_behaves_like "requests that assert edition state",
                  "accessing images for a non editable edition",
                  routes: { images_path: %i[get post] } do
    let(:edition) { create(:edition, :published) }
  end

  it_behaves_like "requests that assert edition state",
                  "accessing an image for a non editable edition",
                  routes: { edit_image_path: %i[get patch],
                            crop_image_path: %i[get patch],
                            download_image_path: %i[get],
                            destroy_image_path: %i[delete] } do
    let(:edition) { create(:edition, :published) }
    let(:route_params) { [edition.document, "image_id"] }
  end

  it_behaves_like "requests that return status",
                  "when an image revision belongs to a different edition",
                  status: :not_found,
                  routes: { edit_image_path: %i[get patch],
                            crop_image_path: %i[get patch],
                            download_image_path: %i[get],
                            destroy_image_path: %i[delete] } do
    let(:edition) { create(:edition) }
    let(:image_revision) { create(:image_revision) }
    let(:route_params) { [edition.document, image_revision] }
  end

  describe "POST /documents/:document/images" do
    let(:edition) { create(:edition) }

    before { stub_publishing_api_put_content(edition.content_id, {}) }

    it "redirects to crop when image is created successfully" do
      stub_asset_manager_receives_an_asset(filename: "960x640.jpg")

      image = fixture_file_upload("files/960x640.jpg")
      post images_path(edition.document), params: { image: image }

      expect(response).to redirect_to(
        crop_image_path(edition.document, Image.last, wizard: "upload"),
      )
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      not_image = fixture_file_upload("files/bad_file.rb")
      post images_path(edition.document),
           params: { image: not_image }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to have_content(
        I18n.t!("requirements.image_upload.unsupported_type.form_message"),
      )
    end
  end

  describe "GET /documents/:document/images/:image_id/crop" do
    it "returns successfully for an image belonging to the edition" do
      image_revision = create(:image_revision)
      edition = create(:edition, image_revisions: [image_revision])

      get crop_image_path(edition.document, image_revision.image_id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /documents/:document/images/:image_id/crop" do
    let(:image_revision) { create(:image_revision) }
    let(:edition) { create(:edition, image_revisions: [image_revision]) }
    let(:crop) { { crop_x: 0, crop_y: 0, crop_width: 960, crop_height: 640 } }

    it "redirects to edit image when in the upload wizard" do
      patch crop_image_path(edition.document, image_revision.image_id, wizard: "upload"),
            params: { image_revision: crop }

      expect(response).to redirect_to(
        edit_image_path(edition.document, image_revision.image_id, wizard: "upload"),
      )
    end

    it "redirects to the images path when outside the wizard" do
      patch crop_image_path(edition.document, image_revision.image_id),
            params: { image_revision: crop }

      expect(response).to redirect_to(images_path(edition.document))
    end
  end

  describe "GET /documents/:document/images/:image_id/edit" do
    it "returns successfully for an image belonging to the edition" do
      image_revision = create(:image_revision)
      edition = create(:edition, image_revisions: [image_revision])

      get edit_image_path(edition.document, image_revision.image_id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /documents/:document/images/:image_id/edit" do
    before do
      stub_asset_manager_receives_an_asset
      stub_any_publishing_api_put_content
    end

    let(:image_revision) { create(:image_revision) }

    it "defaults to redirecting to the editions images index" do
      edition = create(:edition, image_revisions: [image_revision])

      patch edit_image_path(edition.document, image_revision.image_id),
            params: { image_revision: { alt_text: "Alt text" } }
      expect(response).to redirect_to(images_path(edition.document))
    end

    it "redirects to document summary with an alert when lead image is selected" do
      edition = create(:edition, image_revisions: [image_revision])

      patch edit_image_path(edition.document, image_revision.image_id),
            params: { image_revision: { alt_text: "Alt text" }, lead_image: "on" }
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content(
        I18n.t!("documents.show.flashes.lead_image.selected", file: image_revision.filename),
      )
    end

    it "redirects to images index with an alert when lead image is removed" do
      edition = create(:edition, lead_image_revision: image_revision)

      patch edit_image_path(edition.document, image_revision.image_id),
            params: { image_revision: { alt_text: "Alt text" }, lead_image: "off" }
      expect(response).to redirect_to(images_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content(
        I18n.t!("images.index.flashes.lead_image.removed", file: image_revision.filename),
      )
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      edition = create(:edition, image_revisions: [image_revision])
      patch edit_image_path(edition.document, image_revision.image_id),
            params: { image_revision: { alt_text: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to include(I18n.t!("requirements.alt_text.blank.form_message"))
    end
  end

  describe "DELETE /documents/:document/images/:image_id" do
    before { stub_any_publishing_api_put_content }

    let(:image_revision) { create(:image_revision) }

    it "redirects with a lead image alert when the image is the lead image" do
      edition = create(:edition, lead_image_revision: image_revision)
      delete destroy_image_path(edition.document, image_revision.image_id)

      expect(response).to redirect_to(images_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content(
        I18n.t!("images.index.flashes.lead_image.deleted", file: image_revision.filename),
      )
    end

    it "redirects with a deleted alert when the image is not the lead image" do
      edition = create(:edition, image_revisions: [image_revision])
      delete destroy_image_path(edition.document, image_revision.image_id)

      expect(response).to redirect_to(images_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content(
        I18n.t!("images.index.flashes.deleted", file: image_revision.filename),
      )
    end
  end

  describe "GET /documents/:document/images/:image_id/download" do
    it "provides an image download" do
      image_revision = create(:image_revision)
      edition = create(:edition, image_revisions: [image_revision])
      get download_image_path(edition.document, image_revision.image_id)
      expect(response.headers["Content-Disposition"])
        .to match(/attachment; filename="#{image_revision.filename}";/)
    end
  end
end
