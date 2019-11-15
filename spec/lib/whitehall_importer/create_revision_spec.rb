# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateRevision do
  include FixturesHelper

  describe "#call" do
    let(:whitehall_edition) { whitehall_export_with_one_edition["editions"].first }
    let(:translation) { whitehall_edition["translations"].first }
    let(:document) { create(:document, imported_from: "whitehall") }

    context "when creating tags"do
      it "sets role appointments" do
        revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        ).call

        role_appointment = whitehall_edition["role_appointments"].first
        expect(revision.tags["role_appointments"].first).to eq(role_appointment["content_id"])
      end

      it "sets topical events" do
        revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        ).call

        topical_events = whitehall_edition["topical_events"].first
        expect(revision.tags["topical_events"].first).to eq(topical_events["content_id"])
      end

      it "sets world locations" do
        revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        ).call

        world_locations = whitehall_edition["world_locations"].first
        expect(revision.tags["world_locations"].first).to eq(world_locations["content_id"])
      end
    end

    context "when creating organisation associations" do
      it "sets a primary_publishing_organisation" do
        revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        ).call

        primary_organisation = whitehall_edition["organisations"].first
        expect(revision.primary_publishing_organisation_id).to eq(primary_organisation["content_id"])
      end

      it "sets other supporting organisations" do
        revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        ).call

        support_organisation = whitehall_edition["organisations"].last
        expect(revision.supporting_organisation_ids.first).to eq(support_organisation["content_id"])
      end

      it "aborts if there are no organisations" do
        whitehall_edition.delete("organisations")
        create_revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        )

        expect { create_revision.call }.to raise_error(WhitehallImporter::AbortImportError)
      end

      it "aborts if there are no lead organisations" do
        whitehall_edition["organisations"].shift
        create_revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        )

        expect { create_revision.call }.to raise_error(WhitehallImporter::AbortImportError)
      end

      it "aborts if there is more than one lead organisation" do
        whitehall_edition["organisations"].push(
          "id" => 3,
          "content_id" => SecureRandom.uuid,
          "lead" => true,
          "lead_ordering" => 2,
        )
        create_revision = WhitehallImporter::CreateRevision.new(
          document, whitehall_edition, translation
        )

        expect { create_revision.call }.to raise_error(WhitehallImporter::AbortImportError)
      end
    end

    it "changes the ids of embedded contacts" do
      translation["body"] = "[Contact:123]"
      content_id = SecureRandom.uuid
      whitehall_edition["contacts"] = [{ "id" => 123, "content_id" => content_id }]
      revision = WhitehallImporter::CreateRevision.new(
        document, whitehall_edition, translation
      ).call

      expect(revision.contents["body"]).to eq("[Contact:#{content_id}]")
    end

    it "raises AbortImportError when an edition has an unsupported document type" do
      whitehall_edition["news_article_type"] = "unsupported_document"
      create_revision = WhitehallImporter::CreateRevision.new(
        document, whitehall_edition, translation
      )

      expect { create_revision.call }.to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets imported to true on revision" do
      WhitehallImporter::CreateRevision.new(
        document, whitehall_edition, translation
      ).call

      expect(Revision.last.imported).to be true
    end
  end
end
