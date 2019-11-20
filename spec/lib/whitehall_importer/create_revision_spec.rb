# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateRevision do
  include FixturesHelper

  describe ".call" do
    let(:whitehall_edition) { whitehall_export_with_one_edition["editions"].first }
    let(:document) { create(:document, imported_from: "whitehall", locale: "en") }

    context "when creating tags"do
      it "sets role appointments" do
        revision = described_class.call(document, whitehall_edition)

        role_appointment = whitehall_edition["role_appointments"].first
        expect(revision.tags["role_appointments"].first).to eq(role_appointment["content_id"])
      end

      it "sets topical events" do
        revision = described_class.call(document, whitehall_edition)

        topical_events = whitehall_edition["topical_events"].first
        expect(revision.tags["topical_events"].first).to eq(topical_events["content_id"])
      end

      it "sets world locations" do
        revision = described_class.call(document, whitehall_edition)

        world_locations = whitehall_edition["world_locations"].first
        expect(revision.tags["world_locations"].first).to eq(world_locations["content_id"])
      end
    end

    context "when creating organisation associations" do
      it "sets a primary_publishing_organisation" do
        revision = described_class.call(document, whitehall_edition)

        primary_organisation = whitehall_edition["organisations"].first
        expect(revision.primary_publishing_organisation_id).to eq(primary_organisation["content_id"])
      end

      it "sets other supporting organisations" do
        revision = described_class.call(document, whitehall_edition)

        support_organisation = whitehall_edition["organisations"].last
        expect(revision.supporting_organisation_ids.first).to eq(support_organisation["content_id"])
      end

      it "aborts if there are no organisations" do
        whitehall_edition.delete("organisations")
        expect { described_class.call(document, whitehall_edition) }
          .to raise_error(WhitehallImporter::AbortImportError)
      end

      it "aborts if there are no lead organisations" do
        whitehall_edition["organisations"].shift

        expect { described_class.call(document, whitehall_edition) }
          .to raise_error(WhitehallImporter::AbortImportError)
      end

      it "aborts if there is more than one lead organisation" do
        whitehall_edition["organisations"].push(
          "id" => 3,
          "content_id" => SecureRandom.uuid,
          "lead" => true,
          "lead_ordering" => 2,
        )

        expect { described_class.call(document, whitehall_edition) }
          .to raise_error(WhitehallImporter::AbortImportError)
      end
    end

    it "changes the ids of embedded contacts" do
      whitehall_edition["translations"].first["body"] = "[Contact:123]"
      content_id = SecureRandom.uuid
      whitehall_edition["contacts"] = [{ "id" => 123, "content_id" => content_id }]
      revision = described_class.call(document, whitehall_edition)

      expect(revision.contents["body"]).to eq("[Contact:#{content_id}]")
    end

    it "raises WhitehallImporter::AbortImportError when a translation isn't available for the documents locale" do
      french_document = create(:document, imported_from: "whitehall", locale: "fr")

      expect { described_class.call(french_document, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "raises WhitehallImporter::AbortImportError when an edition has an unsupported document type" do
      whitehall_edition["news_article_type"] = "unsupported_document"

      expect { described_class.call(document, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets imported to true on revision" do
      revision = described_class.call(document, whitehall_edition)

      expect(revision.imported).to be true
    end
  end
end
