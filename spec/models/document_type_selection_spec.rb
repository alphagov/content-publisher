require "json"

RSpec.describe DocumentTypeSelection do
  let(:document_type_selections) { YAML.load_file(Rails.root.join("config/document_type_selections.yml")) }

  describe "all configured document types selections are valid" do
    let(:document_type_selection_schema) { JSON.parse(File.read("config/schemas/document_type_selection.json")) }

    it "conforms to the document type selection schema" do
      document_type_selections.each do |document_type_selection|
        validator = JSON::Validator.fully_validate(document_type_selection_schema, document_type_selection)
        expect(validator).to(
          be_empty,
          "Validation for #{document_type_selection['id']} failed: \n\t#{validator.join("\n\t")}",
        )
      end
    end

    it "finds the corresponding object for every string id in the options" do
      document_type_selections.flat_map { |d| d["options"] }.each do |option|
        if option["type"] == "document_type_selection"
          expect(described_class.find(option["id"]))
            .to be_a(described_class)
        end
      end
    end

    it "only allows unique document type selections" do
      ids = document_type_selections.pluck("id")
      expect(ids.size).to eq(ids.uniq.size)
    end
  end

  describe ".all" do
    it "creates a DocumentTypeSelection for each one in the YAML" do
      expect(described_class.all.count).to eq(document_type_selections.count)
    end
  end

  describe ".find" do
    it "returns the corresponding DocumentTypeSelection" do
      expect(described_class.find("news")).to be_a(described_class)
      expect(described_class.find("news").id).to eq("news")
    end

    it "raises a NotFoundError when there is no corresponding entry for the id" do
      expect { described_class.find("unknown_document_type") }
        .to raise_error(DocumentTypeSelection::NotFoundError)
    end
  end
end
