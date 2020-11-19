RSpec.describe "Healthcheck" do
  describe "GET /healthcheck" do
    before do
      populate_default_government_bulk_data
    end

    it "returns a 200 HTTP status" do
      get healthcheck_path
      expect(response).to have_http_status(:ok)
    end

    it "includes a status in the response body" do
      get healthcheck_path
      expect(JSON.parse(response.body)).to have_key("status")
    end

    it "checks ActiveStorage if specified" do
      get healthcheck_path
      expect(JSON.parse(response.body)["checks"]).not_to have_key("active_storage")

      get healthcheck_path, params: { storage: true }
      expect(JSON.parse(response.body)["checks"]).to have_key("active_storage")
    end
  end
end
