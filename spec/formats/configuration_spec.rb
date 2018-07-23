# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Format configuration" do
  supertypes = YAML.load_file("app/formats/supertypes.yml")
  document_types = YAML.load_file("app/formats/document_types.yml")

  supertypes.each do |supertype_schema|
    describe "Supertype #{supertype_schema['id']}" do
      it "has the required attributes for #{supertype_schema['id']}" do
        expect(supertype_schema.keys).to include('id', 'label', 'description')
      end
    end
  end

  document_types.each do |document_type_schema|
    describe "Document type #{document_type_schema['document_type']}" do
      it "has the required attributes" do
        expect(document_type_schema.keys).to include('document_type', 'name', 'supertype')
      end

      it "has a valid supertype" do
        expect(document_type_schema["supertype"]).to be_in(supertypes.pluck("id"))
      end

      it "has a valid document type" do
        expect(document_type_schema["document_type"]).to be_in(GovukSchemas::DocumentTypes.valid_document_types)
      end
    end
  end
end
