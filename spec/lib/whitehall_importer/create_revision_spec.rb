# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateRevision do
  describe ".call" do
    let(:document) { build(:document, imported_from: "whitehall", locale: "en") }

    it "creates a revision" do
      whitehall_edition = build(:whitehall_export_edition)
      expect { described_class.call(document, whitehall_edition) }
        .to change { Revision.count }
        .by(1)
    end

    it "marks the revision as imported" do
      revision = described_class.call(document, build(:whitehall_export_edition))

      expect(revision.imported).to be(true)
    end

    it "sets content from the revision" do
      translation = build(:whitehall_export_translation,
                          locale: "en",
                          title: "Revision title",
                          summary: "Revision summary",
                          base_path: "/a-path")
      whitehall_edition = build(:whitehall_export_edition,
                                translations: [translation])
      revision = described_class.call(document, whitehall_edition)
      expect(revision.title).to eq("Revision title")
      expect(revision.summary).to eq("Revision summary")
      expect(revision.base_path).to eq("/a-path")
    end

    context "when creating images" do
      it "imports a single image" do
        whitehall_image = build(:whitehall_export_image, filename: "foo.jpg")
        whitehall_edition = build(:whitehall_export_edition, images: [whitehall_image])
        revision = nil
        expect { revision = described_class.call(document, whitehall_edition) }
          .to change { Image::Revision.count }.by(1)
        expect(revision.image_revisions.last.caption).to eq(whitehall_image["caption"])
        expect(revision.image_revisions.last.alt_text).to eq(whitehall_image["alt_text"])
        expect(revision.image_revisions.last.filename).to eq("foo.jpg")
      end

      it "ensures that every image filename is unique" do
        whitehall_edition = build(
          :whitehall_export_edition,
          images: [
            build(:whitehall_export_image, filename: "image.jpg"),
            build(:whitehall_export_image, filename: "subdir/image.jpg"),
          ],
        )
        revision = described_class.call(document, whitehall_edition)

        expect(revision.image_revisions.first.blob_revision.filename).to eq("image.jpg")
        expect(revision.image_revisions.last.blob_revision.filename).to eq("image-1.jpg")
      end
    end

    it "changes the ids of embedded contacts" do
      translation = build(:whitehall_export_translation,
                          body: "[Contact:123]")
      content_id = SecureRandom.uuid
      whitehall_edition = build(
        :whitehall_export_edition,
        translations: [translation],
        contacts: [{ "id" => 123, "content_id" => content_id }],
      )
      revision = described_class.call(document, whitehall_edition)

      expect(revision.contents["body"]).to eq("[Contact:#{content_id}]")
    end

    it "aborts when a translation isn't available for the documents locale" do
      translation = build(:whitehall_export_translation, locale: "fr")
      whitehall_edition = build(:whitehall_export_edition,
                                translations: [translation])

      expect { described_class.call(document, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "aborts for a unsupported news_article_type" do
      whitehall_edition = build(:whitehall_export_edition,
                                news_article_type: "unsupported")

      expect { described_class.call(document, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets a primary publishing organisation" do
      lead_organisation = build(:whitehall_export_organisation, :lead)
      whitehall_edition = build(
        :whitehall_export_edition,
        organisations: [lead_organisation],
      )

      revision = described_class.call(document, whitehall_edition)

      expect(revision.primary_publishing_organisation_id)
        .to eq(lead_organisation["content_id"])
    end

    it "sets supporting organisations" do
      lead_organisation = build(:whitehall_export_organisation, :lead)
      supporting_organisation = build(:whitehall_export_organisation)
      whitehall_edition = build(
        :whitehall_export_edition,
        organisations: [lead_organisation, supporting_organisation],
      )

      revision = described_class.call(document, whitehall_edition)

      expect(revision.supporting_organisation_ids)
        .to eq([supporting_organisation["content_id"]])
    end

    it "aborts if there are no organisations" do
      whitehall_edition = build(:whitehall_export_edition, organisations: [])

      expect { described_class.call(document, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "aborts if there are no lead organisations" do
      whitehall_edition = build(
        :whitehall_export_edition,
        organisations: [build(:whitehall_export_organisation)],
      )

      expect { described_class.call(document, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "aborts if there is more than one lead organisation" do
      first_lead_organisation = build(:whitehall_export_organisation, :lead)
      second_lead_organisation = build(:whitehall_export_organisation, :lead)
      whitehall_edition = build(
        :whitehall_export_edition,
        organisations: [first_lead_organisation, second_lead_organisation],
      )

      expect { described_class.call(document, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets role appointments" do
      role_appointment = { "id" => 1, "content_id" => SecureRandom.uuid }
      whitehall_edition = build(:whitehall_export_edition,
                                role_appointments: [role_appointment])

      revision = described_class.call(document, whitehall_edition)

      expect(revision.tags["role_appointments"])
        .to eq([role_appointment["content_id"]])
    end

    it "sets topical events" do
      topical_event = { "id" => 1, "content_id" => SecureRandom.uuid }
      whitehall_edition = build(:whitehall_export_edition,
                                topical_events: [topical_event])

      revision = described_class.call(document, whitehall_edition)

      expect(revision.tags["topical_events"])
        .to eq([topical_event["content_id"]])
    end

    it "sets world locations" do
      world_location = { "id" => 1, "content_id" => SecureRandom.uuid }
      whitehall_edition = build(:whitehall_export_edition,
                                world_locations: [world_location])

      revision = described_class.call(document, whitehall_edition)

      expect(revision.tags["world_locations"].first)
        .to eq(world_location["content_id"])
    end
  end
end
