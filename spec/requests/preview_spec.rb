# frozen_string_literal: true

RSpec.describe "Preview" do
  it_behaves_like "requests that assert edition state",
                  "previewing a live edition",
                  routes: { preview_document_path: %i[get post] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "POST /documents/:document/create-preview" do
    it "redirects to the preview page on success" do
      edition = create(:edition)
      stub_publishing_api_put_content(edition.content_id, {})
      post preview_document_path(edition.document)

      expect(response).to redirect_to(preview_document_path(edition.document))
    end

    it "redirects to the summary page issues in an error when the document isn't publishable" do
      edition = create(:edition, title: "", revision_synced: false)
      post preview_document_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_selector(".gem-c-error-summary",
                          text: I18n.t!("requirements.title.blank.summary_message"))
    end

    it "redirects to the summary page with an error flash when it can't preview the document" do
      stub_publishing_api_isnt_available
      edition = create(:edition)
      post preview_document_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_content(I18n.t!("documents.show.flashes.preview_error.title"))
    end
  end
end
