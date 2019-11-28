# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateEdition do
  describe "#call" do
    let(:document) { create(:document, imported_from: "whitehall", locale: "en") }
    let(:whitehall_document) { build(:whitehall_export_document) }
    let(:user_ids) { { 1 => create(:user).id } }

    it "can import an edition" do
      whitehall_edition = build(:whitehall_export_edition,
                                state: "draft",
                                minor_change: false)
      edition = described_class.call(document: document,
                                     current: true,
                                     whitehall_edition: whitehall_edition,
                                     edition_number: 1,
                                     user_ids: user_ids)

      expect(edition).to be_draft
      expect(edition.number).to eq(1)
      expect(edition.update_type).to eq("major")
    end

    it "can set minor update type" do
      whitehall_edition = build(:whitehall_export_edition, minor_change: true)
      edition = described_class.call(document: document,
                                     current: true,
                                     whitehall_edition: whitehall_edition,
                                     edition_number: 1,
                                     user_ids: user_ids)

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
        described_class.call(document: document,
                             current: true,
                             whitehall_edition: whitehall_edition,
                             edition_number: 1,
                             user_ids: user_ids)
      }.to raise_error(WhitehallImporter::AbortImportError)
    end

    it "defaults to an edition not being flagged as live" do
      whitehall_edition = build(:whitehall_export_edition)
      edition = described_class.call(document: document,
                                     current: true,
                                     whitehall_edition: whitehall_edition,
                                     edition_number: 1,
                                     user_ids: user_ids)

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
      edition = described_class.call(document: document,
                                     current: true,
                                     whitehall_edition: whitehall_edition,
                                     edition_number: 1,
                                     user_ids: user_ids)

      expect(edition).to be_live
    end

    context "when importing an access limited edition" do
      it "creates an access limit" do
        whitehall_edition = build(:whitehall_export_edition, access_limited: true)
        edition = described_class.call(document: document,
                                       current: true,
                                       whitehall_edition: whitehall_edition,
                                       edition_number: 1,
                                       user_ids: user_ids)

        expect(edition.access_limit).to be_present
        expect(edition.access_limit).to be_tagged_organisations
      end
    end

    context "when importing a withdrawn document" do
      it "sets the correct status" do
        whitehall_edition = build(
          :whitehall_export_edition,
          state: "withdrawn",
          revision_history: [
            { "event" => "create", "state" => "published", "whodunnit" => 1 },
            { "event" => "update", "state" => "withdrawn", "whodunnit" => 1 },
          ],
          unpublishing: build(:whitehall_export_unpublishing),
        )

        edition = described_class.call(document: document,
                                       current: true,
                                       whitehall_edition: whitehall_edition,
                                       edition_number: 1,
                                       user_ids: user_ids)

        expect(edition).to be_withdrawn
        expect(edition.statuses.count).to eq(2)
        expect(edition.statuses.first).to be_published
      end
    end
  end
end
