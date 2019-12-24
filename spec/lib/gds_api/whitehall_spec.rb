# frozen_string_literal: true

RSpec.describe GdsApi::Whitehall do
  describe "document_list" do
    let(:whitehall_adapter) { GdsApi::Whitehall.new(Plek.find("whitehall-admin")) }
    let(:whitehall_export_page_1) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 100)) }
    let(:whitehall_export_page_2) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 10)) }

    before do
      stub_request(:get, "https://whitehall-admin.test.gov.uk/government/admin/export/document?lead_organisation=123&type=NewsArticle&page_count=100&page_number=1")
        .to_return(status: 200, body: whitehall_export_page_1.to_json)
      stub_request(:get, "https://whitehall-admin.test.gov.uk/government/admin/export/document?lead_organisation=123&type=NewsArticle&page_count=100&page_number=2")
        .to_return(status: 200, body: whitehall_export_page_2.to_json)
    end

    it "makes a GET request to whitehall for correct number of pages" do
      whitehall_document_list = whitehall_adapter.document_list("123", "NewsArticle")
      expect(whitehall_document_list.next).to have_requested(:get, "https://whitehall-admin.test.gov.uk/government/admin/export/document?lead_organisation=123&type=NewsArticle&page_count=100&page_number=1")
      expect(whitehall_document_list.next).to have_requested(:get, "https://whitehall-admin.test.gov.uk/government/admin/export/document?lead_organisation=123&type=NewsArticle&page_count=100&page_number=2")
      expect { whitehall_document_list.next }.to raise_error(StopIteration)
    end

    it "returns a Hash version of the JSON response for each page" do
      whitehall_document_list = whitehall_adapter.document_list("123", "NewsArticle")
      expect(whitehall_document_list.next).to eq(whitehall_export_page_1)
      expect(whitehall_document_list.next).to eq(whitehall_export_page_2)
    end
  end

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
