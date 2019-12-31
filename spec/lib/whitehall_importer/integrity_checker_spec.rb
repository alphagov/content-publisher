# frozen_string_literal: true

RSpec.describe WhitehallImporter::IntegrityChecker do
  describe "#valid?" do
    let(:edition) { build(:edition) }

    it "returns true if there aren't any problems" do
      stub_publishing_api_has_item(
        content_id: edition.content_id,
        base_path: edition.base_path,
        title: edition.title,
        description: edition.summary,
        document_type: edition.document_type.id,
        schema_name: edition.document_type.publishing_metadata.schema_name,
        details: {
          body: GovspeakDocument.new(edition.contents["body"], edition).payload_html,
        },
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

    it "returns a problem when the titles don't match" do
      stub_publishing_api_has_item(content_id: edition.content_id, title: "title")

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("title doesn't match")
    end

    it "returns a problem when the descriptions don't match" do
      stub_publishing_api_has_item(content_id: edition.content_id, description: "description")

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("description doesn't match")
    end

    it "returns a problem when the document types don't match" do
      stub_publishing_api_has_item(content_id: edition.content_id, document_type: "news_story")

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("document_type doesn't match")
    end

    it "returns a problem when the schema names don't match" do
      stub_publishing_api_has_item(content_id: edition.content_id, schema_name: "news_article")

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("schema_name doesn't match")
    end

    it "returns a problem when the body text doesn't match" do
      stub_publishing_api_has_item(
        content_id: edition.content_id,
        details: {
          body: "body text",
        },
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("body text doesn't match")
    end
  end
end
