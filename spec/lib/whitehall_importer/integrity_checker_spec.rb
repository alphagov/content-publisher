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
    let(:document_type) do
      build :document_type, contents: [
        DocumentType::TitleAndBasePathField.new,
        DocumentType::SummaryField.new,
        DocumentType::BodyField.new,
      ]
    end

    let(:edition) do
      build(:edition,
            document_type_id: document_type.id,
            image_revisions: [build(:image_revision)],
            tags: { "organisations": [] })
    end

    let(:payload) do
      {
        content_id: edition.content_id,
        base_path: "base-path",
        title: "title",
        description: "description",
        document_type: "news_story",
        schema_name: "news_article",
        details: {
          body: "body text",
          image: {
            alt_text: "alt text",
            caption: "caption",
          },
        },
        links: {
          primary_publishing_organisation: [SecureRandom.uuid],
          organisations: [SecureRandom.uuid],
        },
      }
    end

    let(:integrity_check) { WhitehallImporter::IntegrityChecker.new(edition) }

    def problem_message(attribute, expected, actual)
      "#{attribute} doesn't match, expected: #{expected.inspect}, actual: #{actual.inspect}"
    end

    before do
      stub_publishing_api_has_links(content_id: edition.content_id)
      stub_publishing_api_has_item(payload)
    end

    it "returns a problem when the base paths don't match" do
      expect(integrity_check.problems).to include(
        problem_message("base_path", payload[:base_path], edition.base_path),
      )
    end

    it "returns a problem when the titles don't match" do
      expect(integrity_check.problems).to include(
        problem_message("title", payload[:title], edition.title),
      )
    end

    it "returns a problem when the descriptions don't match" do
      expect(integrity_check.problems).to include(
        problem_message("description", payload[:description], edition.summary),
      )
    end

    it "returns a problem when the document types don't match" do
      expect(integrity_check.problems).to include(
        problem_message("document_type",
                        payload[:document_type],
                        edition.document_type.id),
      )
    end

    it "returns a problem when the schema names don't match" do
      edition_schema_name = edition.document_type.publishing_metadata.schema_name
      expect(integrity_check.problems).to include(
        problem_message("schema_name", payload[:schema_name], edition_schema_name),
      )
    end

    it "returns a problem when the body text doesn't match" do
      expect(integrity_check.problems).to include("body text doesn't match")
    end

    it "returns a problem when the image alt_text doesn't match" do
      edition_image = edition.image_revisions.first
      payload_image = payload[:details][:image]

      expect(integrity_check.problems).to include(
        problem_message("image alt_text",
                        payload_image[:alt_text],
                        edition_image.alt_text),
      )
    end

    it "returns a problem when the image caption doesn't match" do
      edition_image = edition.image_revisions.first
      payload_image = payload[:details][:image]

      expect(integrity_check.problems).to include(
        problem_message("image caption",
                        payload_image[:caption],
                        edition_image.caption),
      )
    end

    it "returns a problem when the primary_publishing_organisation doesn't match" do
      expect(integrity_check.problems).to include(
        problem_message("primary_publishing_organisation",
                        payload[:links][:primary_publishing_organisation],
                        edition.tags["primary_publishing_organisation"]),
      )
    end

    it "returns a problem when the organisations don't match" do
      expected = payload[:links][:organisations].inspect
      actual = edition.tags["organisations"].inspect
      message = "organisations don't match, expected: #{expected}, actual: #{actual}"

      expect(integrity_check.problems).to include(message)
    end
  end
end
