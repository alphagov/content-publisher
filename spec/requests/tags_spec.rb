RSpec.describe "Tags" do
  it_behaves_like "requests that assert edition state",
                  "tagging a non editable edition",
                  routes: { tags_path: %i[get patch] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents/:document/tags" do
    let(:tag_field) { DocumentType::WorldLocationsField.new }
    let(:edition) do
      document_type = build(:document_type, tags: [tag_field])
      create(:edition, document_type: document_type)
    end

    it "returns successfully" do
      tag_name = SecureRandom.hex(8)
      stub_publishing_api_has_linkables(
        [{ "content_id" => SecureRandom.uuid, "internal_name" => tag_name }],
        document_type: "world_location",
      )
      get tags_path(edition.document)
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_content(tag_name)
    end

    it "returns service unavailable when the Publishing API is down" do
      stub_publishing_api_isnt_available

      get tags_path(edition.document)

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to have_content(I18n.t!("tags.edit.api_down"))
    end
  end

  describe "PATCH /documents/:document/tags" do
    before { stub_any_publishing_api_put_content }

    it "redirects to document path on successful request" do
      edition = create(:edition)

      patch tags_path(edition.document),
            params: { field: [SecureRandom.uuid] }

      expect(response).to redirect_to(document_path(edition.document))
    end

    it "returns an issue and unprocessable response when a primary publishing "\
       "organisation is not selected" do
      tag_field = DocumentType::PrimaryPublishingOrganisationField.new
      document_type = build(:document_type, tags: [tag_field])
      edition = create(:edition, document_type: document_type)
      stub_publishing_api_has_linkables(
        [{ "content_id" => SecureRandom.uuid, "internal_name" => "Organisation" }],
        document_type: "organisation",
      )

      patch tags_path(edition.document), params: {}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to have_content(
        I18n.t!("requirements.primary_publishing_organisation.blank.form_message"),
      )
    end
  end
end
