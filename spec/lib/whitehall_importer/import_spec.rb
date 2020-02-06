# frozen_string_literal: true

RSpec.describe WhitehallImporter::Import do
  describe ".call" do
    let(:whitehall_user) { build(:whitehall_export_user) }
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
    let(:document_import) do
      create(:whitehall_migration_document_import,
             payload: nil,
             whitehall_document_id: 1,
             content_id: nil,
             document: nil)
    end
    let(:whitehall_export_document) { build(:whitehall_export_document) }

    before do
      allow(WhitehallImporter::IntegrityChecker)
        .to receive(:new)
        .and_return(instance_double(WhitehallImporter::IntegrityChecker, valid?: true))
      stub_whitehall_api_lock_document(document_import.whitehall_document_id)
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export_document
      )
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of pending" do
      document_import = create(:whitehall_migration_document_import, state: "imported")

      expect { described_class.call(document_import) }
        .to raise_error(RuntimeError, "Cannot import with a state of imported")
    end

    it "locks the document in Whitehall" do
      described_class.call(document_import)
      expect(stub_whitehall_api_lock_document(document_import.whitehall_document_id))
        .to have_been_requested
    end

    it "stores the exported Whitehall document data" do
      described_class.call(document_import)

      expect(document_import.payload).to eq(whitehall_export_document)
    end

    it "creates a document" do
      expect { described_class.call(document_import) }
        .to change { Document.count }.by(1)
    end

    it "aborts if a document already exists" do
      content_id = create(:document).content_id
      whitehall_export = build(:whitehall_export_document, content_id: content_id)
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )

      expect { described_class.call(document_import) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets the document as being imported from Whitehall" do
      described_class.call(document_import)

      expect(document_import.document).to be_imported_from_whitehall
    end

    it "sets the timeline entry as Imported from Whitehall" do
      described_class.call(document_import)

      expect(TimelineEntry.last).to be_whitehall_migration
      expect(TimelineEntry.last.details).to be_imported_from_whitehall
    end

    it "associates the created document with the import record" do
      whitehall_export = build(:whitehall_export_document, content_id: SecureRandom.uuid)
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )
      described_class.call(document_import)

      expect(document_import.document.content_id).to eq(whitehall_export["content_id"])
    end

    it "creates users who have never logged into Content Publisher" do
      whitehall_export = build(:whitehall_export_document, users: [whitehall_user])
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )
      described_class.call(document_import)

      expect(User.last.attributes).to match hash_including(
        "uid" => whitehall_user["uid"],
        "name" => whitehall_user["name"],
        "email" => whitehall_user["email"],
        "organisation_slug" => whitehall_user["organisation_slug"],
        "organisation_content_id" => whitehall_user["organisation_content_id"],
      )
    end

    it "does not add users who have logged into Content Publisher" do
      User.create!(uid: whitehall_user["uid"])
      whitehall_export = build(:whitehall_export_document, users: [whitehall_user])
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )

      expect { described_class.call(document_import) }.not_to(change { User.count })
    end

    it "does not create a user who has a nil uid" do
      user = build(:whitehall_export_user, uid: nil)
      whitehall_export = build(:whitehall_export_document, users: [user])
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )

      expect { described_class.call(document_import) }.not_to(change { User.count })
    end

    it "sets created_by_id as the original author" do
      user = User.create!(uid: whitehall_user["uid"])
      edition = build(
        :whitehall_export_edition,
        revision_history: [build(:whitehall_export_revision_history_event,
                                 whodunnit: whitehall_user["id"])],
      )

      whitehall_export = build(:whitehall_export_document,
                               editions: [edition],
                               users: [whitehall_user])
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )
      described_class.call(document_import)

      expect(document_import.document.created_by).to eq(user)
    end

    it "sets current boolean on whether edition is current or not" do
      past_edition = build(
        :whitehall_export_edition,
        created_at: Time.current.yesterday.rfc3339,
        revision_history: [build(:whitehall_export_revision_history_event,
                                 whodunnit: whitehall_user["id"])],
      )
      current_edition = build(
        :whitehall_export_edition,
        revision_history: [build(:whitehall_export_revision_history_event,
                                 whodunnit: whitehall_user["id"])],
      )

      whitehall_export = build(:whitehall_export_document,
                               editions: [past_edition, current_edition],
                               users: [whitehall_user])
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )

      expect(WhitehallImporter::CreateEdition).to receive(:call).with(
        hash_including(current: false),
      ).ordered.and_call_original

      expect(WhitehallImporter::CreateEdition).to receive(:call).with(
        hash_including(current: true),
      ).ordered.and_call_original

      described_class.call(document_import)
    end

    it "sets first_published_at date to publish time of first edition" do
      first_publish_date = Time.current.yesterday.rfc3339
      first_edition = build(
        :whitehall_export_edition,
        revision_history: [
          build(:whitehall_export_revision_history_event),
          build(:whitehall_export_revision_history_event,
                event: "update",
                state: "published",
                created_at: first_publish_date),
        ],
      )
      second_edition = build(
        :whitehall_export_edition,
        revision_history: [
          build(:whitehall_export_revision_history_event),
          build(:whitehall_export_revision_history_event,
                event: "update",
                state: "published",
                created_at: Time.current),
        ],
      )

      whitehall_export = build(:whitehall_export_document,
                               editions: [first_edition, second_edition])
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )

      described_class.call(document_import)

      expect(document_import.document.first_published_at)
        .to eq(first_publish_date)
    end

    it "integrity checks the current and live editions of the imported document" do
      editions = [
        build(:whitehall_export_edition),
        build(:whitehall_export_edition, :published),
      ]
      whitehall_export = build(:whitehall_export_document, editions: editions)
      stub_whitehall_api_document_export(
        document_import.whitehall_document_id, whitehall_export
      )

      described_class.call(document_import)

      expect(WhitehallImporter::IntegrityChecker.new).to have_received(:valid?).twice
    end

    it "aborts if the integrity check fails" do
      allow(WhitehallImporter::IntegrityChecker)
        .to receive(:new)
        .and_return(instance_double(
                      WhitehallImporter::IntegrityChecker,
                      valid?: false,
                      problems: ["foo doesn't match"],
                      proposed_payload: { "foo" => "bar" },
                      edition: build(:edition),
                    ))

      expect { described_class.call(document_import) }
        .to raise_error(WhitehallImporter::IntegrityCheckError)
    end

    it "does not update the document import if the transaction fails" do
      allow(document_import).to receive(:update!).and_call_original
      allow(document_import).to receive(:update!)
                            .with(state: "imported")
                            .and_raise("forced error")
      stub_whitehall_api_document_export(document_import, whitehall_export_document)

      expect { described_class.call(document_import) }.to raise_error("forced error")
      expect(document_import.changed?).to be false
      expect(document_import.document).to be nil
    end
  end

  def stub_whitehall_api_document_export(document_id, whitehall_export)
    stub_request(:get, "#{whitehall_host}/government/admin/export/document/#{document_id}")
      .to_return(status: 200, body: whitehall_export.to_json)
  end

  def stub_whitehall_api_lock_document(document_id)
    stub_request(:post, "#{whitehall_host}/government/admin/export/document/#{document_id}/lock")
  end
end
