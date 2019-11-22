# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateEdition do
  describe "#call" do
    let(:document) { create(:document, imported_from: "whitehall", locale: "en") }
    let(:whitehall_document) { build(:whitehall_export_document) }
    let(:user_ids) { { 1 => create(:user).id } }

    it "can import an edition" do
      whitehall_edition = build(:whitehall_export_edition)
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
      whitehall_edition = build(:whitehall_export_edition, state: "published")
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

    it "sets the status to the user that created it and at the time that was done" do
      whitehall_edition = build(:whitehall_export_edition)
      user = create(:user)

      edition = described_class.call(document: document,
                                     current: true,
                                     whitehall_edition: whitehall_edition,
                                     edition_number: 1,
                                     user_ids: { 1 => user.id })

      expect(edition.status.created_by).to eq(user)
      expect(edition.status.created_at).to eq(whitehall_edition["revision_history"].first["created_at"])
    end

    context "when the document is withdrawn" do
      let(:whitehall_edition) do
        build(:whitehall_export_edition,
              state: "withdrawn",
              revision_history: [
                { "event" => "create", "state" => "draft", "whodunnit" => 1 },
                { "event" => "update", "state" => "published", "whodunnit" => 1 },
                { "event" => "update", "state" => "withdrawn", "whodunnit" => 1 },
              ],
              unpublishing: build(:whitehall_export_unpublishing))
      end
      let(:edition) do
        described_class.call(document: document,
                             current: true,
                             whitehall_edition: whitehall_edition,
                             edition_number: 1,
                             user_ids: user_ids)
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

      it "creates a withdrawal record" do
        expect(edition.status.details).to be_an_instance_of(Withdrawal)
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

    it "aborts when there are no unpublishing details" do
      whitehall_edition = build(
        :whitehall_export_edition,
        state: "withdrawn",
        revision_history: [
          { "event" => "create", "state" => "draft", "whodunnit" => 1 },
          { "event" => "update", "state" => "published", "whodunnit" => 1 },
          { "event" => "update", "state" => "withdrawn", "whodunnit" => 1 },
        ],
        unpublishing: nil,
      )

      expect {
        described_class.call(document: document,
                             current: true,
                             whitehall_edition: whitehall_edition,
                             edition_number: 1,
                             user_ids: user_ids)
      }.to raise_error(WhitehallImporter::AbortImportError)
    end
  end
end
