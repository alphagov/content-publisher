# frozen_string_literal: true

RSpec.describe "Review" do
  describe "POST /documents/:document/submit-for-2i" do
    it_behaves_like "requests that assert edition state",
                    "submitting a non-draft for 2i review",
                    routes: { submit_for_2i_path: %i[post] } do
      let(:edition) { create(:edition, state: :submitted_for_review) }
    end

    it "redirects to document summary with a notification" do
      edition = create(:edition, :publishable)
      post submit_for_2i_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content(
        I18n.t!("documents.show.flashes.submitted_for_review.title"),
      )
    end

    it "redirects to document summary in an error when edition isn't publishable" do
      edition = create(:edition, summary: "")
      post submit_for_2i_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_selector(".gem-c-error-summary",
                          text: I18n.t!("requirements.summary.blank.summary_message"))
    end

    it "redirects to document summary when topics can't be checked" do
      stub_publishing_api_isnt_available

      document_type = build(:document_type, topics: true)
      edition = create(:edition, document_type_id: document_type.id)
      post submit_for_2i_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content(
        I18n.t!("documents.show.flashes.publish_error.title"),
      )
    end
  end

  describe "POST /documents/:document/approve" do
    it_behaves_like "requests that assert edition state",
                    "approving an edition that isn't published but needs 2i review",
                    routes: { approve_path: %i[post] } do
      let(:edition) { create(:edition, :published) }
    end

    it "redirects to document summary with a flash message" do
      edition = create(:edition, :published, state: :published_but_needs_2i)
      post approve_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_content(I18n.t!("documents.show.flashes.approved"))
    end
  end
end
