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
  end
end
