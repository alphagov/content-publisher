RSpec.describe WhitehallImporter::CreateEdition do
  let(:document_import) { build(:whitehall_migration_document_import, document: document) }

  describe "#call" do
    let(:document) { create(:document, imported_from: "whitehall", locale: "en") }
    let(:user_ids) { { 1 => create(:user).id } }

    it "can import an edition" do
      whitehall_edition = build(:whitehall_export_edition)
      edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

      expect(edition).to be_draft
      expect(edition.number).to eq(1)
      expect(edition.update_type).to eq("major")
    end

    it "can set minor update type" do
      whitehall_edition = build(:whitehall_export_edition, minor_change: true)
      edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

      expect(edition.update_type).to eq("minor")
    end

    it "aborts when an edition has an unsupported locale" do
      whitehall_edition = build(
        :whitehall_export_edition,
        translations: [
          build(:whitehall_export_translation, locale: "fr"),
          build(:whitehall_export_translation, locale: "en"),
        ],
      )

      expect {
        described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)
      }.to raise_error(WhitehallImporter::AbortImportError)
    end

    it "defaults to an edition not being flagged as live" do
      whitehall_edition = build(:whitehall_export_edition)
      edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

      expect(edition).not_to be_live
    end

    it "flags published editions as live" do
      whitehall_edition = build(
        :whitehall_export_edition,
        state: "published",
        revision_history: [
          build(:whitehall_export_revision_history_event),
          build(:whitehall_export_revision_history_event,
                event: "update", state: "published"),
        ],
      )
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition)

      expect(edition).to be_live
    end

    it "does not mark the edition as synced with Publishing API" do
      whitehall_edition = build(:whitehall_export_edition)
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition)

      expect(edition.revision_synced).to be false
    end

    it "sets the editors of an edition" do
      user_ids = {
        1 => create(:user).id,
        2 => create(:user).id,
      }

      whitehall_edition = build(
        :whitehall_export_edition,
        revision_history: [
          build(:whitehall_export_revision_history_event, whodunnit: 1),
          build(:whitehall_export_revision_history_event, whodunnit: 2),
        ],
      )

      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition,
                                     user_ids: user_ids)

      expect(edition.editors.count).to eq(2)
    end

    context "with editorial remarks" do
      let(:content_publisher_user) { create(:user) }
      let(:whitehall_user_id) { rand(100) }
      let(:user_ids) { { whitehall_user_id => content_publisher_user.id } }
      let(:create_event) do
        build(:whitehall_export_revision_history_event,
              event: "create",
              whodunnit: whitehall_user_id,
              created_at: 1.week.ago.noon)
      end

      it "imports a create revision history event" do
        whitehall_edition = build(:whitehall_export_edition,
                                  revision_history: [create_event])
        edition = described_class.call(document_import: document_import,
                                       whitehall_edition: whitehall_edition,
                                       user_ids: user_ids)
        timeline_entry = edition.timeline_entries.first
        expect(timeline_entry.attributes)
          .to match a_hash_including("entry_type" => "whitehall_migration",
                                     "created_by_id" => content_publisher_user.id,
                                     "created_at" => 1.week.ago.noon)
        expect(timeline_entry.details.attributes)
          .to match a_hash_including("entry_type" => "first_created",
                                     "contents" => {})
      end

      it "imports a published revision history event" do
        publish_event = build(:whitehall_export_revision_history_event,
                              whodunnit: whitehall_user_id,
                              event: "update",
                              state: "published",
                              created_at: 1.day.ago.noon)
        whitehall_edition = build(:whitehall_export_edition,
                                  revision_history: [create_event,
                                                     publish_event])
        edition = described_class.call(document_import: document_import,
                                       whitehall_edition: whitehall_edition,
                                       user_ids: user_ids)
        timeline_entry = edition.timeline_entries.order(:created_at).last
        expect(timeline_entry.attributes)
          .to match a_hash_including("entry_type" => "whitehall_migration",
                                     "created_by_id" => content_publisher_user.id,
                                     "created_at" => 1.day.ago.noon)
        expect(timeline_entry.details.attributes)
          .to match a_hash_including("entry_type" => "published",
                                     "contents" => {})
      end

      it "imports an editorial remark event" do
        event = build(:whitehall_export_editorial_remark_event,
                      author_id: whitehall_user_id,
                      body: "Another note",
                      created_at: 1.day.ago.noon)
        whitehall_edition = build(:whitehall_export_edition,
                                  revision_history: [create_event],
                                  editorial_remarks: [event])
        edition = described_class.call(document_import: document_import,
                                       whitehall_edition: whitehall_edition,
                                       user_ids: user_ids)
        timeline_entry = edition.timeline_entries.order(:created_at).last
        expect(timeline_entry.attributes)
          .to match a_hash_including("entry_type" => "whitehall_migration",
                                     "created_by_id" => content_publisher_user.id,
                                     "created_at" => 1.day.ago.noon)
        expect(timeline_entry.details.attributes)
          .to match a_hash_including("entry_type" => "internal_note",
                                     "contents" => { "body" => "Another note" })
      end

      it "imports a fact check request event" do
        event = build(:whitehall_export_fact_check_event,
                      requestor_id: whitehall_user_id,
                      email_address: "someone@somewhere.com",
                      instructions: "Do something",
                      comments: nil,
                      created_at: 1.day.ago.noon)
        whitehall_edition = build(:whitehall_export_edition,
                                  revision_history: [create_event],
                                  fact_check_requests: [event])
        edition = described_class.call(document_import: document_import,
                                       whitehall_edition: whitehall_edition,
                                       user_ids: user_ids)
        timeline_entry = edition.timeline_entries.order(:created_at).last
        expect(timeline_entry.attributes)
          .to match a_hash_including("entry_type" => "whitehall_migration",
                                     "created_by_id" => content_publisher_user.id,
                                     "created_at" => 1.day.ago.noon)
        expect(timeline_entry.details.attributes)
          .to match a_hash_including("entry_type" => "fact_check_request",
                                     "contents" => {
                                       "email_address" =>
                                          "someone@somewhere.com",
                                       "instructions" => "Do something",
                                     })
      end

      it "imports a fact check response event" do
        response_received_at = 1.day.ago.noon
        event = build(:whitehall_export_fact_check_event,
                      requestor_id: whitehall_user_id,
                      email_address: "someone@somewhere.com",
                      comments: "Hello World",
                      created_at: 2.days.ago.noon,
                      updated_at: response_received_at)
        whitehall_edition = build(:whitehall_export_edition,
                                  revision_history: [create_event],
                                  fact_check_requests: [event])
        edition = described_class.call(document_import: document_import,
                                       whitehall_edition: whitehall_edition,
                                       user_ids: user_ids)
        response_entry = edition.timeline_entries.order(:created_at).last
        expect(response_entry.attributes)
          .to match a_hash_including("entry_type" => "whitehall_migration",
                                     "created_at" => response_received_at,
                                     "created_by_id" => nil)
        expect(response_entry.details.attributes)
          .to match a_hash_including("entry_type" => "fact_check_response",
                                     "contents" => {
                                       "email_address" =>
                                         "someone@somewhere.com",
                                       "comments" => "Hello World",
                                     })
      end
    end

    context "when importing an access limited edition" do
      it "creates an access limit" do
        whitehall_edition = build(:whitehall_export_edition,
                                  access_limited: true)
        edition = described_class.call(document_import: document_import,
                                       whitehall_edition: whitehall_edition)

        expect(edition.access_limit).to be_present
        expect(edition.access_limit).to be_tagged_organisations
      end
    end

    it "attributes the status to the user that created it and at the time that was done" do
      whitehall_user_id = 1
      user = create(:user)
      create_event = build(:whitehall_export_revision_history_event,
                           event: "create", whodunnit: whitehall_user_id)
      whitehall_edition = build(:whitehall_export_edition,
                                revision_history: [create_event])
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition,
                                     user_ids: { whitehall_user_id => user.id })

      expect(edition.status.created_by).to eq(user)
      expect(edition.status.created_at).to eq(
        whitehall_edition["revision_history"].first["created_at"],
      )
    end

    context "when the document is withdrawn" do
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              state: "withdrawn",
              revision_history: [
                build(:whitehall_export_revision_history_event),
                build(:whitehall_export_revision_history_event,
                      event: "update", state: "published"),
                build(:whitehall_export_revision_history_event,
                      event: "update", state: "withdrawn"),
              ],
              unpublishing: build(:whitehall_export_unpublishing))
      end

      let(:edition) do
        described_class.call(document_import: document_import,
                             whitehall_edition: whitehall_edition)
      end

      it "creates two statuses" do
        expect(edition.statuses.count).to eq(2)
      end

      it "sets the correct withdrawn status" do
        expect(edition).to be_withdrawn
      end

      it "sets the correct previous status" do
        expect(edition.statuses.first).to be_published
      end

      it "sets the correct withdrawal metadata" do
        expect(edition.status.details.withdrawn_at.rfc3339).to eq(
          whitehall_edition["unpublishing"]["created_at"],
        )
        expect(edition.status.details.public_explanation).to eq(
          whitehall_edition["unpublishing"]["explanation"],
        )
      end
    end

    context "when an unpublished edition has not been edited" do
      let(:created_at) { Time.current.yesterday.rfc3339 }
      let(:updated_at) { Time.current.rfc3339 }
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              revision_history: [
                build(:whitehall_export_revision_history_event,
                      created_at: created_at),
                build(:whitehall_export_revision_history_event,
                      event: "update", state: "published"),
                build(:whitehall_export_revision_history_event,
                      event: "update", state: "draft", created_at: updated_at),
              ],
              unpublishing: build(:whitehall_export_unpublishing,
                                  alternative_url: "https://www.gov.uk/gators",
                                  unpublishing_reason: "Consolidated into another GOV.UK page",
                                  explanation: "Gator"))
      end

      it "creates an edition with a status of removed" do
        edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

        expect(edition).to be_removed
      end

      it "sets the correct removal metadata" do
        edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

        removal = edition.status.details
        expect(removal.explanatory_note).to eq(whitehall_edition["unpublishing"]["explanation"])
        expect(removal.alternative_url).to eq(whitehall_edition["unpublishing"]["alternative_url"])
        expect(removal.redirect).to be_truthy
      end

      it "sets the correct timestamps on the edition" do
        edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

        expect(edition.created_at).to eq(created_at)
        expect(edition.updated_at).to eq(updated_at)
        expect(edition.last_edited_at).to eq(updated_at)
      end
    end

    context "when an unpublished edition has been edited" do
      let(:created_at) { Time.current.rfc3339 }
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              revision_history: [
                build(:whitehall_export_revision_history_event),
                build(:whitehall_export_revision_history_event,
                      event: "update", state: "published"),
                build(:whitehall_export_revision_history_event,
                      event: "update",
                      state: "draft",
                      created_at: 5.minutes.ago.rfc3339),
                build(:whitehall_export_revision_history_event,
                      event: "update", state: "draft", created_at: created_at),
              ],
              unpublishing: build(:whitehall_export_unpublishing,
                                  alternative_url: "https://www.gov.uk/flextension",
                                  unpublishing_reason: "Consolidated into another GOV.UK page",
                                  explanation: "Brexit is being delayed again"))
      end

      it "creates two editions" do
        expect {
          described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)
        } .to change(Edition, :count).by(2)
      end

      it "creates an edition with a status of removed" do
        described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

        expect(document.editions.first).to be_removed
      end

      it "sets the correct removal metadata" do
        described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

        removal = document.editions.first.status.details
        expect(removal.explanatory_note).to eq(whitehall_edition["unpublishing"]["explanation"])
        expect(removal.alternative_url).to eq(whitehall_edition["unpublishing"]["alternative_url"])
        expect(removal.redirect).to be_truthy
      end

      it "creates a draft edition and assigns as current" do
        edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

        expect(edition).to be_draft
        expect(edition.current).to be_truthy
      end

      it "sets the correct timestamps on the edition" do
        edition = described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)

        expect(edition.created_at).to eq(created_at)
        expect(edition.updated_at).to eq(created_at)
      end
    end

    it "aborts when there are no unpublishing details" do
      whitehall_edition = build(
        :whitehall_export_edition,
        state: "withdrawn",
        revision_history: [
          build(:whitehall_export_revision_history_event),
          build(:whitehall_export_revision_history_event,
                event: "update", state: "published"),
          build(:whitehall_export_revision_history_event,
                event: "update", state: "withdrawn"),
        ],
        unpublishing: nil,
      )

      expect {
        described_class.call(document_import: document_import,
                             whitehall_edition: whitehall_edition)
      }.to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  context "when the document is scheduled" do
    let(:document) { create(:document, imported_from: "whitehall", locale: "en") }

    it "sets the edition as scheduled" do
      publish_time = Date.tomorrow.beginning_of_day
      whitehall_edition = build(:whitehall_export_edition,
                                :scheduled,
                                scheduled_publication: publish_time.rfc3339)
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition)

      expect(edition).to be_scheduled
      expect(edition.status.details.publish_time).to eq(publish_time)
    end

    it "sets a previous submitted_for_review status when the whitehall edition was submitted" do
      whitehall_edition = build(:whitehall_export_edition,
                                :scheduled,
                                previous_state: "submitted")
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition)

      statuses = edition.statuses.map(&:state)
      expect(statuses).to contain_exactly("submitted_for_review", "scheduled")
      expect(edition.status.details.pre_scheduled_status).to be_submitted_for_review
    end

    it "sets a previous submitted_for_review status when the whitehall edition was a draft" do
      whitehall_edition = build(:whitehall_export_edition,
                                :scheduled,
                                previous_state: "draft")
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition)

      statuses = edition.statuses.map(&:state)
      expect(statuses).to contain_exactly("draft", "scheduled")
      expect(edition.status.details.pre_scheduled_status).to be_draft
    end

    it "marks a non force published whitehall edition as reviewed" do
      whitehall_edition = build(:whitehall_export_edition,
                                :scheduled,
                                force_published: false)
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition)
      expect(edition.status.details.reviewed).to be true
    end

    it "marks a force published whitehall edition as needing review" do
      whitehall_edition = build(:whitehall_export_edition,
                                :scheduled,
                                force_published: true)
      edition = described_class.call(document_import: document_import,
                                     whitehall_edition: whitehall_edition)
      expect(edition.status.details.reviewed).to be false
    end

    it "aborts when there is no scheduled publication date" do
      whitehall_edition = build(:whitehall_export_edition,
                                :scheduled,
                                scheduled_publication: nil)

      expect {
        described_class.call(document_import: document_import, whitehall_edition: whitehall_edition)
      }.to raise_error(
        WhitehallImporter::AbortImportError,
        "Cannot create scheduled status without scheduled_publication",
      )
    end
  end
end
