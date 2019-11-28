# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateEdition do
  describe "#call" do
    let(:document) { create(:document, imported_from: "whitehall", locale: "en") }
    let(:whitehall_document) { build(:whitehall_export_document) }
    let(:user_ids) { { 1 => create(:user).id } }

    it "can import an edition" do
      whitehall_edition = build(:whitehall_export_edition)
      edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

      expect(edition).to be_draft
      expect(edition.number).to eq(1)
      expect(edition.update_type).to eq("major")
    end

    it "can set minor update type" do
      whitehall_edition = build(:whitehall_export_edition, minor_change: true)
      edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

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
        described_class.call(document: document, whitehall_edition: whitehall_edition)
      }.to raise_error(WhitehallImporter::AbortImportError)
    end

    it "defaults to an edition not being flagged as live" do
      whitehall_edition = build(:whitehall_export_edition)
      edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

      expect(edition).not_to be_live
    end

    it "flags published editions as live" do
      whitehall_edition = build(
        :whitehall_export_edition,
        state: "published",
        revision_history: [
          build(:revision_history_event),
          build(:revision_history_event, event: "update", state: "published"),
        ],
      )
      edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

      expect(edition).to be_live
    end

    context "when importing an access limited edition" do
      it "creates an access limit" do
        whitehall_edition = build(:whitehall_export_edition, access_limited: true)
        edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

        expect(edition.access_limit).to be_present
        expect(edition.access_limit).to be_tagged_organisations
      end
    end

    it "attributes the status to the user that created it and at the time that was done" do
      whitehall_edition = build(:whitehall_export_edition)
      user = create(:user)
      edition = described_class.call(document: document,
                                     whitehall_edition: whitehall_edition,
                                     user_ids: { 1 => user.id })

      expect(edition.status.created_by).to eq(user)
      expect(edition.status.created_at).to eq(whitehall_edition["revision_history"].first["created_at"])
    end

    context "when the document is withdrawn" do
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              state: "withdrawn",
              revision_history: [
                build(:revision_history_event),
                build(:revision_history_event, event: "update", state: "published"),
                build(:revision_history_event, event: "update", state: "withdrawn"),
              ],
              unpublishing: build(:whitehall_export_unpublishing))
      end

      let(:edition) do
        described_class.call(document: document, whitehall_edition: whitehall_edition)
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
      let(:created_at) { Time.zone.now.yesterday.rfc3339 }
      let(:updated_at) { Time.zone.now.rfc3339 }
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              revision_history: [
                build(:revision_history_event, created_at: created_at),
                build(:revision_history_event, event: "update", state: "published"),
                build(:revision_history_event, event: "update", state: "draft", created_at: updated_at),
              ],
              unpublishing: build(:whitehall_export_unpublishing,
                                  alternative_url: "https://www.gov.uk/gators",
                                  unpublishing_reason: "Consolidated into another GOV.UK page",
                                  explanation: "Gator"))
      end

      it "creates an edition with a status of removed" do
        edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

        expect(edition.removed?).to be_truthy
      end

      it "sets the correct removal metadata" do
        edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

        removal = edition.status.details
        expect(removal.explanatory_note).to eq(whitehall_edition["unpublishing"]["explanation"])
        expect(removal.alternative_path).to eq(whitehall_edition["unpublishing"]["alternative_url"])
        expect(removal.redirect).to be_truthy
      end

      it "sets the correct timestamps on the edition" do
        edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

        expect(edition.created_at).to eq(created_at)
        expect(edition.updated_at).to eq(updated_at)
      end
    end

    context "when an unpublished edition has been edited" do
      let(:created_at) { Time.zone.now.rfc3339 }
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              revision_history: [
                build(:revision_history_event),
                build(:revision_history_event, event: "update", state: "published"),
                build(:revision_history_event, event: "update", state: "draft"),
                build(:revision_history_event, event: "update", state: "draft", created_at: created_at),
              ],
              unpublishing: build(:whitehall_export_unpublishing,
                                  alternative_url: "https://www.gov.uk/flextension",
                                  unpublishing_reason: "Consolidated into another GOV.UK page",
                                  explanation: "Brexit is being delayed again"))
      end

      it "creates two editions" do
        expect {
          described_class.call(document: document, whitehall_edition: whitehall_edition)
        } .to change { Edition.count }.by(2)
      end

      it "creates an edition with a status of removed" do
        described_class.call(document: document, whitehall_edition: whitehall_edition)

        expect(document.editions.first.removed?).to be_truthy
      end

      it "sets the correct removal metadata" do
        described_class.call(document: document, whitehall_edition: whitehall_edition)

        removal = document.editions.first.status.details
        expect(removal.explanatory_note).to eq(whitehall_edition["unpublishing"]["explanation"])
        expect(removal.alternative_path).to eq(whitehall_edition["unpublishing"]["alternative_url"])
        expect(removal.redirect).to be_truthy
      end

      it "creates a draft edition and assigns as current" do
        edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

        expect(edition.draft?).to be_truthy
        expect(edition.current).to be_truthy
      end

      it "sets the correct timestamps on the edition" do
        edition = described_class.call(document: document, whitehall_edition: whitehall_edition)

        expect(edition.created_at).to eq(created_at)
        expect(edition.updated_at).to eq(created_at)
      end
    end

    it "aborts when there are no unpublishing details" do
      whitehall_edition = build(
        :whitehall_export_edition,
        state: "withdrawn",
        revision_history: [
          build(:revision_history_event),
          build(:revision_history_event, event: "update", state: "published"),
          build(:revision_history_event, event: "update", state: "withdrawn"),
        ],
        unpublishing: nil,
      )

      expect {
        described_class.call(document: document, whitehall_edition: whitehall_edition)
      }.to raise_error(WhitehallImporter::AbortImportError)
    end
  end
end
