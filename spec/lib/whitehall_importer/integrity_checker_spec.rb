# frozen_string_literal: true

RSpec.describe WhitehallImporter::IntegrityChecker do
  describe "#valid?" do
    let(:edition) do
      build(
        :edition,
        tags: {
          primary_publishing_organisation: [SecureRandom.uuid],
          organisations: [SecureRandom.uuid],
        },
      )
    end

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
        links: {
          primary_publishing_organisation: edition.tags["primary_publishing_organisation"].to_a,
          organisations: edition.tags["organisations"].to_a + edition.tags["primary_publishing_organisation"].to_a,
        },
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.valid?).to be true
    end

    it "compares against organisations in linkset links if there no edition links" do
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

      stub_publishing_api_has_links(
        content_id: edition.content_id,
        links: {
          primary_publishing_organisation: edition.tags["primary_publishing_organisation"].to_a,
          organisations: edition.tags["organisations"].to_a + edition.tags["primary_publishing_organisation"].to_a,
        },
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.valid?).to be true
    end
  end

  describe "#problems" do
    let(:edition) { build(:edition) }

    before do
      stub_publishing_api_has_links(content_id: edition.content_id)
    end

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

    it "returns a problem when the image alt_text doesn't match" do
      stub_publishing_api_has_item(
        content_id: edition.content_id,
        details: {
          image: {
            alt_text: "alt text",
          },
        },
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("image alt_text doesn't match")
    end

    it "returns a problem when the image caption doesn't match" do
      stub_publishing_api_has_item(
        content_id: edition.content_id,
        details: {
          image: {
            caption: "caption",
          },
        },
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("image caption doesn't match")
    end

    it "returns a problem when the primary_publishing_organisation doesn't match" do
      stub_publishing_api_has_item(
        content_id: edition.content_id,
        links: {
          primary_publishing_organisation: [SecureRandom.uuid],
        },
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("primary_publishing_organisation doesn't match")
    end

    it "returns a problem when the organisations don't match" do
      stub_publishing_api_has_item(
        content_id: edition.content_id,
        links: {
          organisations: [SecureRandom.uuid],
        },
      )

      integrity_check = WhitehallImporter::IntegrityChecker.new(edition)
      expect(integrity_check.problems).to include("organisations don't match")
    end
  end
end
