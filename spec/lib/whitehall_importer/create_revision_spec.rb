RSpec.describe WhitehallImporter::CreateRevision do
  describe ".call" do
    let(:document) { build(:document, imported_from: "whitehall", locale: "en") }
    let(:document_import) { build(:whitehall_migration_document_import, document:) }

    it "creates a revision" do
      whitehall_edition = build(:whitehall_export_edition)
      expect { described_class.call(document_import, whitehall_edition) }
        .to change(Revision, :count)
        .by(1)
    end

    it "marks the revision as imported" do
      revision = described_class.call(document_import, build(:whitehall_export_edition))

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
      revision = described_class.call(document_import, whitehall_edition)
      expect(revision.title).to eq("Revision title")
      expect(revision.summary).to eq("Revision summary")
      expect(revision.base_path).to eq("/a-path")
    end

    it "sets backdated_to when the first edition has been backdated" do
      backdated_to = Time.zone.now.yesterday.rfc3339
      whitehall_edition = build(:whitehall_export_edition,
                                first_published_at: backdated_to)
      document_import = build(:whitehall_migration_document_import,
                              document:,
                              payload: build(:whitehall_export_document, editions: [whitehall_edition]))

      revision = described_class.call(document_import, whitehall_edition)

      expect(revision.backdated_to).to eq(backdated_to)
    end

    it "sets backdated_to when the following edition has been backdated" do
      backdated_to = 1.week.ago.rfc3339
      whitehall_edition = build(:whitehall_export_edition,
                                :published,
                                published_at: Time.zone.yesterday.rfc3339)
      backdated_whitehall_edition = build(:whitehall_export_edition,
                                          first_published_at: backdated_to)
      document_import = build(:whitehall_migration_document_import,
                              document:,
                              payload: build(:whitehall_export_document,
                                             editions: [whitehall_edition, backdated_whitehall_edition]))

      revision = described_class.call(document_import, backdated_whitehall_edition)

      expect(revision.backdated_to).to eq(backdated_to)
    end

    it "does not set backdated_to when the first edition has not been backdated" do
      whitehall_edition = build(:whitehall_export_edition)

      revision = described_class.call(document_import, whitehall_edition)

      expect(revision.backdated_to).to be_nil
    end

    it "does not set backdated_to when the following edition has not been backdated" do
      published_at = Time.zone.now.rfc3339
      whitehall_edition = build(:whitehall_export_edition, :published, published_at:)
      following_whitehall_edition = build(:whitehall_export_edition, first_published_at: published_at)
      document_import = build(:whitehall_migration_document_import,
                              document:,
                              payload: build(:whitehall_export_document,
                                             editions: [whitehall_edition, following_whitehall_edition]))

      revision = described_class.call(document_import, following_whitehall_edition)

      expect(revision.backdated_to).to be_nil
    end

    context "when creating images" do
      it "imports a single image" do
        whitehall_image = build(:whitehall_export_image, filename: "foo.jpg")
        whitehall_edition = build(:whitehall_export_edition, images: [whitehall_image])
        revision = nil
        expect { revision = described_class.call(document_import, whitehall_edition) }
          .to change(Image::Revision, :count).by(1)
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
        revision = described_class.call(document_import, whitehall_edition)

        expect(revision.image_revisions.first.blob_revision.filename).to eq("image.jpg")
        expect(revision.image_revisions.last.blob_revision.filename).to eq("image-1.jpg")
      end

      it "skips any image it has encountered before with same metadata" do
        image = build(:whitehall_export_image, filename: "image.jpg")
        revision1 = described_class.call(document_import, build(:whitehall_export_edition, images: [image]))
        revision2 = described_class.call(document_import, build(:whitehall_export_edition, images: [image]))
        expect(revision1.image_revisions.count).to eq(1)
        expect(revision1.image_revisions).to eq(revision2.image_revisions)
      end

      it "creates a new revision for image it has encountered before with updated metadata" do
        image1 = build(:whitehall_export_image, filename: "image.jpg", alt_text: "Some text")
        image2 = build(:whitehall_export_image, filename: "image.jpg", alt_text: "Some revised text")
        described_class.call(document_import, build(:whitehall_export_edition, images: [image1]))
        described_class.call(document_import, build(:whitehall_export_edition, images: [image2]))
        expect(Image.last.image_revisions.count).to eq(2)
        expect(Image.last.image_revisions.first.alt_text).to eq("Some text")
        expect(Image.last.image_revisions.second.alt_text).to eq("Some revised text")
      end

      it "uses the first image as the lead image" do
        whitehall_edition = build(
          :whitehall_export_edition,
          images: [
            build(:whitehall_export_image, filename: "first.jpg"),
            build(:whitehall_export_image, filename: "second.jpg"),
          ],
        )
        revision = described_class.call(document_import, whitehall_edition)

        expect(revision.lead_image_revision.filename).to eq("first.jpg")
      end
    end

    context "when creating file_attachments" do
      it "imports a single file_attachment" do
        whitehall_edition = build(
          :whitehall_export_edition,
          attachments: [
            build(:whitehall_export_file_attachment, filename: "attach.txt"),
          ],
        )

        expect { described_class.call(document_import, whitehall_edition) }
          .to change(FileAttachment::Revision, :count).by(1)
      end

      it "ensures that every file_attachment filename is unique" do
        whitehall_edition = build(
          :whitehall_export_edition,
          attachments: [
            build(:whitehall_export_file_attachment, filename: "attach.txt"),
            build(:whitehall_export_file_attachment, filename: "subdir/attach.txt"),
          ],
        )
        revision = described_class.call(document_import, whitehall_edition)

        expect(revision.file_attachment_revisions.first.blob_revision.filename).to eq("attach.txt")
        expect(revision.file_attachment_revisions.last.blob_revision.filename).to eq("attach-1.txt")
      end

      it "skips any attachment it has encountered before" do
        attachment = build(:whitehall_export_file_attachment, filename: "attach.txt")
        revision1 = described_class.call(document_import, build(:whitehall_export_edition, attachments: [attachment]))
        revision2 = described_class.call(document_import, build(:whitehall_export_edition, attachments: [attachment]))
        expect(revision1.file_attachment_revisions.count).to eq(1)
        expect(revision1.file_attachment_revisions).to eq(revision2.file_attachment_revisions)
      end
    end

    it "passes body through the EmbedBodyReferences service" do
      body = "Foo Bar"
      whitehall_edition = build(
        :whitehall_export_edition,
        translations: [build(:whitehall_export_translation, body:)],
        images: [build(:whitehall_export_image, filename: "foo.jpg")],
        attachments: [build(:whitehall_export_file_attachment, filename: "attach.txt")],
      )
      expect(WhitehallImporter::EmbedBodyReferences).to receive(:call).with(
        body: "Foo Bar",
        contacts: [],
        images: ["foo.jpg"],
        attachments: ["attach.txt"],
      ).and_call_original
      described_class.call(document_import, whitehall_edition)
    end

    it "aborts when a translation isn't available for the documents locale" do
      translation = build(:whitehall_export_translation, locale: "fr")
      whitehall_edition = build(:whitehall_export_edition,
                                translations: [translation])

      expect { described_class.call(document_import, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "aborts for a unsupported news_article_type" do
      whitehall_edition = build(:whitehall_export_edition,
                                news_article_type: "unsupported")

      expect { described_class.call(document_import, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets a primary publishing organisation" do
      lead_organisation = build(:whitehall_export_organisation, :lead)
      whitehall_edition = build(
        :whitehall_export_edition,
        organisations: [lead_organisation],
      )

      revision = described_class.call(document_import, whitehall_edition)

      expect(revision.primary_publishing_organisation_id)
        .to eq(lead_organisation["content_id"])
    end

    context "when creating organisations with multiple lead orgs" do
      let(:first_lead_organisation) { build(:whitehall_export_organisation, :lead) }
      let(:second_lead_organisation) { build(:whitehall_export_organisation, :lead, lead_ordering: 2) }
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              organisations: [first_lead_organisation, second_lead_organisation])
      end

      it "sets the first lead organisation as the primary publishing organisation" do
        revision = described_class.call(document_import, whitehall_edition)

        expect(revision.primary_publishing_organisation_id)
          .to eq(first_lead_organisation["content_id"])
      end

      it "sets the remaining lead organisations as supportings organisations" do
        revision = described_class.call(document_import, whitehall_edition)

        expect(revision.supporting_organisation_ids)
          .to eq([second_lead_organisation["content_id"]])
      end
    end

    it "sets supporting organisations" do
      lead_organisation = build(:whitehall_export_organisation, :lead)
      supporting_organisation = build(:whitehall_export_organisation)
      whitehall_edition = build(
        :whitehall_export_edition,
        organisations: [lead_organisation, supporting_organisation],
      )

      revision = described_class.call(document_import, whitehall_edition)

      expect(revision.supporting_organisation_ids)
        .to eq([supporting_organisation["content_id"]])
    end

    it "aborts if there are no organisations" do
      whitehall_edition = build(:whitehall_export_edition, organisations: [])

      expect { described_class.call(document_import, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "aborts if there are no lead organisations" do
      whitehall_edition = build(
        :whitehall_export_edition,
        organisations: [build(:whitehall_export_organisation)],
      )

      expect { described_class.call(document_import, whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets role appointments" do
      role_appointment = { "id" => 1, "content_id" => SecureRandom.uuid }
      whitehall_edition = build(:whitehall_export_edition,
                                role_appointments: [role_appointment])

      revision = described_class.call(document_import, whitehall_edition)

      expect(revision.tags["role_appointments"])
        .to eq([role_appointment["content_id"]])
    end

    it "sets topical events" do
      topical_event = { "id" => 1, "content_id" => SecureRandom.uuid }
      whitehall_edition = build(:whitehall_export_edition,
                                topical_events: [topical_event])

      revision = described_class.call(document_import, whitehall_edition)

      expect(revision.tags["topical_events"])
        .to eq([topical_event["content_id"]])
    end

    it "sets world locations" do
      world_location = { "id" => 1, "content_id" => SecureRandom.uuid }
      whitehall_edition = build(:whitehall_export_edition,
                                world_locations: [world_location])

      revision = described_class.call(document_import, whitehall_edition)

      expect(revision.tags["world_locations"].first)
        .to eq(world_location["content_id"])
    end
  end
end
