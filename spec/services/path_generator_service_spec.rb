# frozen_string_literal: true

RSpec.describe PathGeneratorService do
  describe ".path" do
    it "generates a base path which is unique to our database" do
      service = PathGeneratorService.new
      original_document = create(:document)
      new_document = build(:document, document_type: original_document.document_type)
      publishing_api_has_lookups("#{original_document.base_path}": nil)
      expect(service.path(new_document, original_document.title)).to eq("#{original_document.base_path}-1")
    end

    it "raises a 'Path unable to be generated' when many variations of that path are in use" do
      service = PathGeneratorService.new(2)
      document = build(:document)
      prefix = document.document_type_schema.path_prefix
      ["#{prefix}/a-title",
       "#{prefix}/a-title-1",
       "#{prefix}/a-title-2"].each do |path|
        create(:document, base_path: path)
      end
      expect { service.path(document, "A title") }.to raise_error(PathGeneratorService::ErrorGeneratingPath, "Already >2 paths with same title.")
    end
  end
end
