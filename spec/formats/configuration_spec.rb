# frozen_string_literal: true

RSpec.describe "Format configuration", format: true do
  SupertypeSchema.all.each do |schema|
    describe "Supertype #{schema.id}" do
      it "has the required attributes for #{schema.id}" do
        expect(schema.id).to_not be_blank
        expect(schema.label).to_not be_blank
        expect(schema.description).to_not be_blank
      end
    end
  end

  DocumentTypeSchema.all.each do |schema|
    describe "Document type #{schema.id}" do
      it "has the required attributes" do
        expect(schema.id).to_not be_blank
        expect(schema.label).to_not be_blank
      end

      if schema.managed_elsewhere
        it "has the required attributes for managed_elsewhere" do
          expect(schema.managed_elsewhere.keys).to contain_exactly("hostname", "path")
        end
      else
        it "has the required attributes for publishing_metadata" do
          expect(schema.publishing_metadata.rendering_app).to_not be_blank
          expect(schema.publishing_metadata.schema_name).to_not be_blank
        end
      end

      it "has a valid supertype" do
        expect(schema.supertype).to be_a(SupertypeSchema)
        expect(schema.supertype.managed_elsewhere).to be_falsey
      end

      it "has a valid document type" do
        expect(schema.id).to be_in(GovukSchemas::DocumentTypes.valid_document_types)
      end
    end
  end
end
