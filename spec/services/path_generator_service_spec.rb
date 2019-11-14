# frozen_string_literal: true

RSpec.describe PathGeneratorService do
  describe ".call" do
    let(:document) { create(:document, :with_current_edition) }

    it "generates a base path which is unique to our database" do
      new_document = build(:document, document_type_id: document.document_type_id)
      stub_publishing_api_has_lookups("#{document.current_edition.base_path}": nil)

      expect(PathGeneratorService.call(new_document, document.current_edition.title))
        .to eq("#{document.current_edition.base_path}-1")
    end

    it "raises an error when many variations of that path are in use" do
      prefix = document.document_type.path_prefix
      existing_paths = ["#{prefix}/a-title", "#{prefix}/a-title-1", "#{prefix}/a-title-2"]
      existing_paths.each { |path| create(:edition, base_path: path) }

      expect { PathGeneratorService.call(document, "A title", max_repeated_titles: 2) }
        .to raise_error("Already >2 paths with same title.")
    end
  end
end
