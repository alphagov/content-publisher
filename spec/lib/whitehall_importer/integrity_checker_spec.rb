# frozen_string_literal: true

RSpec.describe WhitehallImporter::IntegrityChecker do
  describe "#valid?" do
    let(:edition) { build(:edition) }

    it "returns true if there aren't any problems" do
      stub_publishing_api_has_item(
        content_id: edition.content_id,
        base_path: edition.base_path,
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.valid?).to be true
    end
  end

  describe "#problems" do
    let(:edition) { build(:edition) }

    it "returns a problem when the base paths don't match" do
      stub_publishing_api_has_item(content_id: edition.content_id, base_path: "base-path")

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("base_path doesn't match")
    end
  end
end
