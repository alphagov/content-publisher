RSpec.describe "Errors" do
  shared_examples "an error response" do |code, status|
    title = "code #{status.to_s.titleize}"
    it "returns a #{title} response" do
      get "/#{code}"
      expect(response).to have_http_status(status)
      expect(response.body).to include(I18n.t!("errors.#{status}.title"))
    end

    it "returns a #{title} for unauthenticated users" do
      ClimateControl.modify GDS_SSO_MOCK_INVALID: "true" do
        get "/#{code}"
        expect(response).to have_http_status(status)
        expect(response.body).to include(I18n.t!("errors.#{status}.title"))
      end
    end
  end

  describe "/400" do
    it_behaves_like "an error response", 400, :bad_request
  end

  describe "/403" do
    it_behaves_like "an error response", 403, :forbidden
  end

  describe "/404" do
    it_behaves_like "an error response", 404, :not_found
  end

  describe "/422" do
    it_behaves_like "an error response", 422, :unprocessable_entity
  end

  describe "/500" do
    it_behaves_like "an error response", 500, :internal_server_error

    it "copes if warden is unavailable" do
      allow_any_instance_of(ErrorsController) # rubocop:disable RSpec/AnyInstance
        .to receive(:warden)
        .and_return(nil)
      get "/500"
      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include(I18n.t!("errors.internal_server_error.title"))
    end
  end

  describe "GET /any-path-for-a-document" do
    it "returns a not found response when a document doesn't exist" do
      get document_path("document-that-does-not-exist")

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "ANY /document-path-using-local-data" do
    it "returns service unavailable when local data is unavailable" do
      # This is a somewhat contrived example, hopefully this can be replaced
      # when there's a simple way to trigger this error
      expect(Edition).to receive(:find_current)
        .and_raise(BulkData::LocalDataUnavailableError)

      get document_path("#{SecureRandom.uuid}:en")

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include(I18n.t!("errors.local_data_unavailable.title"))
    end
  end

  describe "ANY /pre-release-document-path" do
    it "returns forbidden when the document type is pre-release" do
      pre_release_document_type = build(:document_type, :pre_release)
      edition = create(:edition, document_type: pre_release_document_type)
      user = build(:user, permissions: %w[signin])

      login_as(user)
      get document_path(edition.document)

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include(I18n.t!("errors.forbidden.title"))
    end
  end
end
