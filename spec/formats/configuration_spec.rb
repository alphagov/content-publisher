# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Format configuration" do
  SupertypeSchema.all.each do |supertype_schema|
    describe "Supertype #{supertype_schema.id}" do
      it "has the required attributes for #{supertype_schema.id}" do
        expect(supertype_schema.id).to_not be_blank
        expect(supertype_schema.label).to_not be_blank
        expect(supertype_schema.description).to_not be_blank
      end
    end
  end

  DocumentTypeSchema.all.each do |document_type_schema|
    describe "Document type #{document_type_schema.id}" do
      it "has the required attributes" do
        expect(document_type_schema.id).to_not be_blank
        expect(document_type_schema.name).to_not be_blank
      end

      it "has a valid supertype" do
        expect(document_type_schema.supertype).to be_a(SupertypeSchema)
      end

      it "has a valid document type" do
        expect(document_type_schema.id).to be_in(GovukSchemas::DocumentTypes.valid_document_types)
      end
    end
  end
end
