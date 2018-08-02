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

    it "appends a count to URLs which are currently in use" do
      service = PathGeneratorService.new
      @document = create(:document, :with_body)
      prefix = @document.document_type_schema.path_prefix
      publishing_api_has_lookups("#{prefix}/a-title": "a-content-id", "#{prefix}/a-title-1": nil)
      expect(service.path(@document, "A title")).to eq("#{prefix}/a-title-1")
    end

    it "raises a 'Path unable to be generated' when the URL and 5 variations already exist in publishing-api" do
      service = PathGeneratorService.new
      @document = create(:document, :with_body)
      prefix = @document.document_type_schema.path_prefix
      publishing_api_has_lookups(
        "#{prefix}/a-title": "a-content-id",
        "#{prefix}/a-title-1": "a-content-id",
        "#{prefix}/a-title-2": "a-content-id",
        "#{prefix}/a-title-3": "a-content-id",
        "#{prefix}/a-title-4": "a-content-id",
        "#{prefix}/a-title-5": "a-content-id",
      )
      expect { service.path(@document, "A title") }.to raise_error(PathGeneratorService::ErrorGeneratingPath, "Already >5 paths with same title.")
    end
  end
end
