# frozen_string_literal: true

RSpec.describe "New Document" do
  describe "GET /documents/choose-document-type" do
    it "shows supertype when a supertype managed by content publisher is selected" do
      supertype = Supertype.all.reject(&:managed_elsewhere).first
      get choose_document_type_path, params: { supertype: supertype.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_content(I18n.t!("supertypes.#{supertype.id}.label"))
    end

    it "redirects when a supertype managed elsewhere is selected" do
      supertype = Supertype.all.find(&:managed_elsewhere)
      get choose_document_type_path, params: { supertype: supertype.id }
      expect(response).to redirect_to(supertype.managed_elsewhere_url)
    end

    it "returns an unprocessable response with an issue when a supertype isn't selected" do
      get choose_document_type_path
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to have_content(I18n.t!("requirements.supertype.not_selected.form_message"))
    end
  end

  describe "POST /documents/create" do
    let(:supertype_id) { Supertype.all.first.id }

    it "redirects to document edit content when a content publisher managed document type is selected" do
      document_type = build(:document_type)
      post create_document_path,
           params: { supertype: supertype_id, document_type: document_type.id }

      expect(response).to redirect_to(content_path(Document.last))
      follow_redirect!
      expect(response.body).to have_content(document_type.label.downcase)
    end

    it "redirects when a document type managed elsewhere is selected" do
      document_type = build(
        :document_type,
        managed_elsewhere: { "hostname" => "whitehall",
                             "path" => "/document-type" },
      )
      post create_document_path,
           params: { supertype: supertype_id, document_type: document_type.id }

      expect(response)
        .to redirect_to("https://whitehall.test.gov.uk/document-type")
    end

    it "returns an unprocessable response with an issue when a document type isn't selected" do
      post create_document_path, params: { supertype: supertype_id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to have_content(
        I18n.t!("requirements.document_type.not_selected.form_message"),
      )
    end
  end
end
