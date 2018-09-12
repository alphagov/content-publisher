# frozen_string_literal: true

RSpec.describe DocumentUrl do
  let(:document) { build(:document, base_path: "/foo", content_id: "d2547c42-8ed3-49f5-baeb-6112f98c2bf9") }

  describe "#public_url" do
    it "returns the URL" do
      url = DocumentUrl.new(document).public_url
      expect(url).to eq("https://www.test.gov.uk/foo")
    end

    it "returns nil without a base_path" do
      document.update!(base_path: nil)
      url = DocumentUrl.new(document).public_url
      expect(url).to be_nil
    end
  end

  describe "#preview_url" do
    it "returns the URL" do
      url = DocumentUrl.new(document).preview_url
      expect(url).to eq("https://draft-origin.test.gov.uk/foo")
    end

    it "returns nil without a base_path" do
      document.update!(base_path: nil)
      url = DocumentUrl.new(document).preview_url
      expect(url).to be_nil
    end
  end

  describe "#secret_preview_url" do
    it "returns the URL" do
      url = DocumentUrl.new(document).secret_preview_url
      expect(url).to eq("https://draft-origin.test.gov.uk/foo?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMzMxMzEzMS0zMzY1LTQ4MzgtYjk2My0zNDM3MzYzNTMxNjYifQ.nsYQ81gx2DKs2XQanFQIZzgkq_Ofw4C3Jys9II2RFoQ")
    end

    it "returns nil without a base_path" do
      document.update!(base_path: nil)
      url = DocumentUrl.new(document).secret_preview_url
      expect(url).to be_nil
    end
  end
end
