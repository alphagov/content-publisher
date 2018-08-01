# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PathGeneratorService do
  describe '.path' do
    it "converts a title into a base path when there is no duplicate" do
      service = PathGeneratorService.new
      @document = create(:document, :with_body)
      prefix = @document.document_type_schema.path_prefix
      publishing_api_has_lookups("#{prefix}/a-title": nil)
      expect(service.path(@document, "A title")).to eq("#{prefix}/a-title")
    end

    it "raises a 'Duplicate path error' when a generated base path exists in Publishing API" do
      service = PathGeneratorService.new
      @document = create(:document, :with_body)
      prefix = @document.document_type_schema.path_prefix
      publishing_api_has_lookups("#{prefix}/a-title": "a-content-id")
      expect(service.path(@document, "A title")).to be false
    end
  end
end
