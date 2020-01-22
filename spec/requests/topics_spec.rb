# frozen_string_literal: true

RSpec.describe "Topics" do
  include TopicsHelper

  let(:edition) { create(:edition) }

  before do
    stub_publishing_api_has_taxonomy
    stub_any_publishing_api_no_links
  end

  describe "GET /documents/:document/topics" do
    it "returns successfully" do
      get topics_path(edition.document)
      expect(response).to have_http_status(:ok)
    end

    it "returns a service unavailable when the Publishing API fails" do
      stub_publishing_api_isnt_available

      get topics_path(edition.document)
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to have_content(I18n.t!("topics.edit.api_down"))
    end
  end

  describe "PATCH /documents/:document/topics" do
    let(:params) { { topics: %w[level_one_topic level_two_topic], version: 1 } }

    it "redirects to document summary with a success notification" do
      stub_any_publishing_api_patch_links

      patch topics_path(edition.document), params: params

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_content(I18n.t!("documents.show.flashes.topics_updated"))
    end

    it "redirects to document summary with an alert when the Publishing API errors" do
      stub_publishing_api_isnt_available

      patch topics_path(edition.document), params: params

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_content(I18n.t!("documents.show.flashes.topic_update_error.title"))
    end

    it "redirects to topics with an alert when there is a topic version conflict" do
      stub_publishing_api_patch_links_conflict(
        edition.content_id,
        "links" => { "taxons" => [], "topics" => [] },
        "previous_version" => 2,
      )

      patch topics_path(edition.document), params: { topics: [], version: 2 }

      expect(response).to redirect_to(topics_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to have_content(I18n.t!("topics.edit.flashes.topic_update_conflict.title"))
    end
  end
end
