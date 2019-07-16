# frozen_string_literal: true

RSpec.describe "Errors" do
  describe "/400" do
    it "returns a bad request response" do
      get "/400"
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include(I18n.t!("errors.bad_request.title"))
    end
  end

  describe "/404" do
    it "returns a not found response" do
      get "/404"
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include(I18n.t!("errors.not_found.title"))
    end
  end

  describe "/422" do
    it "returns an unprocessable entity response" do
      get "/422"
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t!("errors.unprocessable_entity.title"))
    end
  end

  describe "/500" do
    it "returns an internal server error response" do
      get "/500"
      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include(I18n.t!("errors.internal_server_error.title"))
    end
  end
end
