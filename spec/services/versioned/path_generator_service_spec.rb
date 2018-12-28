# frozen_string_literal: true

RSpec.describe Versioned::PathGeneratorService do
  describe "#path" do
    it "generates a base path which is unique to our database" do
      service = Versioned::PathGeneratorService.new
      original_document = create(:versioned_document, :with_current_edition)
      new_document = build(:document, document_type_id: original_document.document_type_id)
      publishing_api_has_lookups("#{original_document.current_edition_base_path}": nil)
      expect(service.path(new_document, original_document.current_edition_title))
        .to eq("#{original_document.current_edition_base_path}-1")
    end

    it "raises a 'Path unable to be generated' when many variations of that path are in use" do
      service = Versioned::PathGeneratorService.new(2)
      document = build(:versioned_document, :with_current_edition)

      prefix = document.document_type.path_prefix
      existing_paths = ["#{prefix}/a-title", "#{prefix}/a-title-1", "#{prefix}/a-title-2"]
      existing_paths.each { |path| create(:versioned_edition, base_path: path) }

      expect { service.path(document, "A title") }
        .to raise_error(Versioned::PathGeneratorService::ErrorGeneratingPath, "Already >2 paths with same title.")
    end
  end
end
