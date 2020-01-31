# frozen_string_literal: true

RSpec.describe "Publish" do
  it_behaves_like "requests that assert edition state",
                  "publishing a non editable edition",
                  routes: { publish_path: %i[get post] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents/:document/publish" do
    it "returns sucessfully when edition is publishable" do
      edition = create(:edition, :publishable)
      get publish_path(edition.document)

      expect(response).to have_http_status(:ok)
      expect(response.body)
        .to have_content(I18n.t!("publish.confirmation.title"))
    end

    it "redirects to summary issues in an error when edition isn't publishable" do
      edition = create(:edition, summary: "")
      get publish_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_selector(".gem-c-error-summary",
                          text: I18n.t!("requirements.summary.blank.summary_message"))
    end

    it "redirects to document summary when topics can't be checked" do
      stub_publishing_api_isnt_available

      document_type = build(:document_type, topics: true)
      edition = create(:edition, document_type: document_type)
      get publish_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_content(I18n.t!("documents.show.flashes.publish_error.title"))
    end
  end

  describe "POST /documents/:document/publish" do
    before do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_publish
    end

    it "redirects to a success page when publishing is successful" do
      edition = create(:edition, :publishable)
      post publish_path(edition.document),
           params: { review_status: "reviewed" }

      expect(response).to redirect_to(published_path(edition.document))
    end

    it "redirects to document summary with an error when publishing fails" do
      stub_publishing_api_isnt_available
      edition = create(:edition, :publishable)
      post publish_path(edition.document),
           params: { review_status: "reviewed" }

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!

      expect(response.body).to have_content(
        I18n.t!("documents.show.flashes.publish_error.title"),
      )
    end

    it "returns an unprocessable response with an issue when a review status isn't provided" do
      edition = create(:edition, :publishable)
      post publish_path(edition.document),
           params: { review_status: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to have_content(
        I18n.t!("requirements.review_status.not_selected.form_message"),
      )
    end
  end

  describe "GET /documents/:document/published" do
    it_behaves_like "requests that assert edition state",
                    "viewing published status of a non-published edition",
                    routes: { published_path: %i[get] } do
      let(:edition) { create(:edition) }
    end

    it "returns successfully when edition is published" do
      edition = create(:edition, :published)
      get published_path(edition.document)

      expect(response).to have_http_status(:ok)
      expect(response.body)
        .to have_content(I18n.t!("publish.published.reviewed.title"))
    end

    it "returns successfully when edition is published but needs 2i" do
      edition = create(:edition, :published, state: :published_but_needs_2i)
      get published_path(edition.document)

      expect(response).to have_http_status(:ok)
      expect(response.body).to have_content(
        I18n.t!("publish.published.published_without_review.title"),
      )
    end
  end
end
