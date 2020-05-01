RSpec.describe "Featured Attachments" do
  it_behaves_like "requests that assert edition state",
                  "accessing featured attachments for a non editable edition",
                  routes: { featured_attachments_path: %i[get],
                            reorder_featured_attachments_path: %i[get patch] } do
    let(:edition) { create(:edition, :published) }
  end

  it_behaves_like "requests that return status",
                  "accessing featured attachments for an edition that doesn't allow them",
                  status: :not_found,
                  routes: { featured_attachments_path: %i[get],
                            reorder_featured_attachments_path: %i[get patch] } do
    let(:edition) { create(:edition) }
    let(:route_params) { [edition.document] }
  end

  describe "GET /documents/:document/attachments" do
    it "returns successfully" do
      document_type = build(:document_type, attachments: "featured")
      edition = create(:edition, document_type: document_type)

      get featured_attachments_path(edition.document)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /documents/:document/attachments/reorder" do
    it "returns successfully" do
      document_type = build(:document_type, attachments: "featured")
      edition = create(:edition, document_type: document_type)

      get reorder_featured_attachments_path(edition.document)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /documents/:document/attachments/reorder" do
    it "redirects to the attachments index" do
      file_attachment = build(:file_attachment_revision)
      document_type = build(:document_type, attachments: "featured")
      stub_any_publishing_api_put_content
      stub_asset_manager_receives_an_asset

      edition = create(:edition, document_type: document_type,
                                 file_attachment_revisions: [file_attachment])

      patch reorder_featured_attachments_path(edition.document),
            params: { attachments: { ordering: { "FileAttachment1" => 2 } } }

      expect(response).to redirect_to(featured_attachments_path(edition.document))
    end
  end
end
