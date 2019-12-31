# frozen_string_literal: true

RSpec.describe GdsApi::WhitehallExport do
  describe "document_export" do
    let(:whitehall_adapter) { GdsApi::WhitehallExport.new(Plek.find("whitehall-admin")) }
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
    let(:whitehall_export) { build(:whitehall_export_document) }

    before do
      stub_request(:get, "#{whitehall_host}/government/admin/export/document/123")
        .to_return(status: 200, body: whitehall_export.to_json)
    end

    it "makes a GET request to whitehall" do
      expect(whitehall_adapter.document_export("123")).to have_requested(:get, "#{whitehall_host}/government/admin/export/document/123")
    end
  end
end
