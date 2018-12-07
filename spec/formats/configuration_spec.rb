# frozen_string_literal: true

RSpec.describe "Format configuration", format: true do
  Supertype.all.each do |supertype|
    describe "Supertype #{supertype.id}" do
      it "has the required attributes for #{supertype.id}" do
        expect(supertype.id).to_not be_blank
        expect(supertype.label).to_not be_blank
        expect(supertype.description).to_not be_blank
      end
    end
  end

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
