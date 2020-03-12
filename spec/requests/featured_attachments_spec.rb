RSpec.describe "Featured Attachments" do
  it_behaves_like "requests that assert edition state",
                  "accessing featured attachments for a non editable edition",
                  routes: { featured_attachments_path: %i[get] } do
    let(:edition) { create(:edition, :published) }
  end

  it_behaves_like "requests that return status",
                  "accessing featured attachments for an edition that doesn't allow them",
                  status: :not_found,
                  routes: { featured_attachments_path: %i[get] } do
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

  describe "GET /documents/:document/attachments/:attachment_id/edit" do
    it "returns successfully" do
      document_type = build(:document_type, attachments: "featured")
      file_attachment_revision = create(:file_attachment_revision)
      edition = create(:edition,
                       document_type: document_type,
                       file_attachment_revisions: [file_attachment_revision])

      get edit_featured_attachment_path(edition.document,
                                        file_attachment_revision.file_attachment_id)
      expect(response).to have_http_status(:ok)
    end
  end
end
