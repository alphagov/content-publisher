# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DocumentTypeSchema do
  describe '#fields' do
    it 'is an empty array by default' do
      schema = DocumentTypeSchema.new

      expect(schema.fields).to eql([])
    end
  end
end
