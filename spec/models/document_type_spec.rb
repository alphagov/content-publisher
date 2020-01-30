# frozen_string_literal: true

require "json"

RSpec.describe DocumentType do
  let(:document_types) { YAML.load_file(Rails.root.join("config/document_types.yml")) }

  describe "all configured document types are valid" do
    it "should conform to the document type schema" do
      document_type_schema = JSON.parse(File.read("config/schemas/document_type.json"))
      document_types.each do |document_type|
        validator = JSON::Validator.fully_validate(document_type_schema, document_type)
        expect(validator).to(
          be_empty,
          "Validation for #{document_type['id']} failed: \n\t#{validator.join("\n\t")}",
        )
      end
    end

    it "should have a valid document type that exists in GovukSchemas" do
      document_types.each do |document_type|
        unless document_type["managed_elsewhere"]
          expect(document_type["id"]).to be_in(GovukSchemas::DocumentTypes.valid_document_types)
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

  describe ".clear" do
    it "resets the DocumentType.all return value" do
      preexisting_doctypes = DocumentType.all.count
      build(:document_type)
      expect(DocumentType.all.count).to eq(preexisting_doctypes + 1)
      DocumentType.clear
      expect(DocumentType.all.count).to eq(preexisting_doctypes)
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
