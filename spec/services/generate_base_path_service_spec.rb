RSpec.describe GenerateBasePathService do
  describe ".call" do
    let(:edition) { create(:edition) }

    it "copes if the proposed title is nil or blank" do
      prefix = edition.document_type.path_prefix
      expect(described_class.call(edition, title: nil)).to eq("#{prefix}/")
      expect(described_class.call(edition, title: " ")).to eq("#{prefix}/")
    end

    it "generates a base path which is unique to our database" do
      new_edition = build(:edition)
      stub_publishing_api_has_lookups("#{edition.base_path}": nil)

      expect(described_class.call(new_edition, title: edition.title))
        .to eq("#{edition.base_path}-1")
    end

    it "preserves the base path when the title does not change" do
      expect(described_class.call(edition, title: edition.title))
        .to eq(edition.base_path)
    end

    it "raises an error when many variations of that path are in use" do
      prefix = edition.document_type.path_prefix
      existing_paths = ["#{prefix}/a-title", "#{prefix}/a-title-1", "#{prefix}/a-title-2"]
      existing_paths.each { |path| create(:edition, base_path: path) }

      expect { described_class.call(edition, title: "A title", max_repeated_titles: 2) }
        .to raise_error("Already >2 paths with same title.")
    end
  end
end
