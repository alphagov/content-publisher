# frozen_string_literal: true

RSpec.describe GdsApi::Whitehall do
  describe "document_export" do
    let(:whitehall_adapter) { GdsApi::Whitehall.new(Plek.find("whitehall-admin")) }
    let(:whitehall_export) { build(:whitehall_export_document) }

    before do
      stub_request(:get, "https://whitehall-admin.test.gov.uk/government/admin/export/document/123")
        .to_return(status: 200, body: whitehall_export.to_json)
    end

    it "makes a GET request to whitehall" do
      expect(whitehall_adapter.document_export("123")).to have_requested(:get, "https://whitehall-admin.test.gov.uk/government/admin/export/document/123")
    end

    it "returns a Hash version of the JSON response" do
      expect(whitehall_adapter.document_export("123")).to eq(whitehall_export)
    end
  end
end
