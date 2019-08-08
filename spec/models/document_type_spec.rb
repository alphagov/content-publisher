# frozen_string_literal: true

RSpec.describe DocumentType do
  describe ".find" do
    it "returns a DocumentType when it's a known document_type" do
      expect(DocumentType.find("press_release")).to be_a(DocumentType)
    end

    it "raises a RuntimeError when we don't know the document_type" do
      expect { DocumentType.find("unknown_document_type") }
        .to raise_error(RuntimeError, "Document type unknown_document_type not found")
    end
  end

  describe "#managed_elsewhere_url" do
    it "returns a full URL" do
      document_type = DocumentType.find("consultation")
      path = "https://whitehall-admin.test.gov.uk/government/admin/consultations/new"
      expect(document_type.managed_elsewhere_url).to eq(path)
    end
  end
end
