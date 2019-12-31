# frozen_string_literal: true

RSpec.describe DocumentType do
  describe "all configured document types are valid" do
    DocumentType.all.each do |document_type|
      describe "Document type #{document_type.id}" do
        it "has the required attributes" do
          expect(document_type.id).to_not be_blank
          expect(document_type.label).to_not be_blank
        end

        if document_type.managed_elsewhere
          it "has the required attributes for managed_elsewhere" do
            expect(document_type.managed_elsewhere.keys).to contain_exactly("hostname", "path")
          end
        else
          it "has the required attributes for publishing_metadata" do
            expect(document_type.publishing_metadata.rendering_app).to_not be_blank
            expect(document_type.publishing_metadata.schema_name).to_not be_blank
          end

          it "has a valid document type" do
            expect(document_type.id).to be_in(GovukSchemas::DocumentTypes.valid_document_types)
          end
        end
      end
    end
  end

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
