# frozen_string_literal: true

RSpec.describe "Backdate" do
  it_behaves_like "requests that assert edition state",
                  "backdating a non editable edition",
                  routes: { backdate_path: %i[get patch delete] } do
    let(:edition) { create(:edition, :published) }
  end

  it_behaves_like "requests that assert edition state",
                  "backdating after the first edition",
                  routes: { backdate_path: %i[get patch delete] } do
    let(:edition) { create(:edition, number: 2) }
  end

  describe "PATCH /documents/:document/backdate" do
    before { stub_any_publishing_api_put_content }

    it "redirects to document summary on success" do
      edition = create(:edition)
      patch backdate_path(edition.document),
            params: { backdate: { date: { day: "25",
                                          month: "12",
                                          year: "2019" } } }

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to have_content("25 December 2019")
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      edition = create(:edition)
      patch backdate_path(edition.document),
            params: { backdate: { date: { day: "",
                                          month: "",
                                          year: "" } } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to have_content(I18n.t!("requirements.backdate_date.invalid.form_message"))
    end
  end

  describe "DELETE /documents/:document/backdate" do
    before { stub_any_publishing_api_put_content }

    it "redirects to document summary" do
      edition = create(:edition)
      delete backdate_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body).to include(
        I18n.t!("documents.show.content_settings.backdate.no_backdate"),
      )
    end
  end
end
