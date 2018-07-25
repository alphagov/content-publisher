# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DocumentTypeSchema do
  describe ".find" do
    it "returns a DocumentTypeSchema when it's a known document_type" do
      expect(DocumentTypeSchema.find("press_release")).to be_a(DocumentTypeSchema)
    end

    it "raises a RuntimeError when we don't know the document_type" do
      expect { DocumentTypeSchema.find("unknown_document_type") }
        .to raise_error(RuntimeError, "Document type unknown_document_type not found")
    end
  end

  describe '#fields' do
    it 'is an empty array by default' do
      schema = DocumentTypeSchema.new

      expect(schema.fields).to eql([])
    end
  end
end
