# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateStatus do
  describe ".call" do
    let(:user_ids) { {} }
    let(:revision) { build(:revision) }

    it "returns a status" do
      status = described_class.call(revision,
                                    build(:whitehall_export_edition),
                                    user_ids)
      expect(status).to be_a(Status)
    end

    it "attributes the status to the user that created it and at the time that was done" do
      created_at = Time.zone.parse("2019-01-01")
      whitehall_edition = build(
        :whitehall_export_edition,
        state: "draft",
        revision_history: [
          {
            "event" => "create",
            "state" => "draft",
            "whodunnit" => 1,
            "created_at" => created_at.rfc3339,
          },
        ],
      )
      user = create(:user)

      status = described_class.call(revision, whitehall_edition, 1 => user.id)
      expect(status.created_by).to eq(user)
      expect(status.created_at).to eq(created_at)
    end

    it "sets the correct state when Whitehall document state is 'published'" do
      whitehall_edition = build(:whitehall_export_edition,
                                state: "published")

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status).to be_published
    end

    it "sets the correct state when Whitehall document is force published" do
      whitehall_edition = build(:whitehall_export_edition,
                                state: "published",
                                force_published: true)

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status).to be_published_but_needs_2i
    end

    it "sets the correct state when Whitehall document state is 'rejected'" do
      whitehall_edition = build(:whitehall_export_edition, state: "rejected")

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status).to be_submitted_for_review
    end

    it "sets the correct state when Whitehall document state is 'submitted'" do
      whitehall_edition = build(:whitehall_export_edition, state: "submitted")

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status).to be_submitted_for_review
    end

    it "sets the correct state when Whitehall document state is 'superseded'" do
      whitehall_edition = build(:whitehall_export_edition, state: "superseded")

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status).to be_superseded
    end

    it "aborts when revision history is missing for state" do
      whitehall_edition = build(:whitehall_export_edition, revision_history: [])

      expect { described_class.call(revision, whitehall_edition, user_ids) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "raises WhitehallImporter::AbortImportError when edition has an unsupported state" do
      whitehall_edition = build(:whitehall_export_edition, state: "unsupported")
      expect { described_class.call(revision, whitehall_edition, user_ids) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "allows the default state to be overwritten by a another valid whitehall state" do
      whitehall_edition = build(:whitehall_export_edition,
                                state: "superseded",
                                revision_history: [
                                  { "event" => "create", "state" => "published", "whodunnit" => 1 },
                                  { "event" => "update", "state" => "superseded", "whodunnit" => 1 },
                                ])

      status = described_class.call(
        revision, whitehall_edition, user_ids, whitehall_edition_state: "published"
      )

      expect(status).to be_published
    end

    context "when the document is withdrawn" do
      let(:edition) { create(:edition, :published) }

      it "aborts when there are no unpublishing details" do
        whitehall_edition = build(:whitehall_export_edition,
                                  state: "withdrawn",
                                  unpublishing: nil)

        expect { described_class.call(revision, whitehall_edition, user_ids, edition: edition) }
          .to raise_error(WhitehallImporter::AbortImportError)
      end

      it "sets the Withdrawal details for a withdrawn document" do
        unpublishing = build(:whitehall_export_unpublishing)
        whitehall_edition = build(:whitehall_export_edition,
                                  state: "withdrawn",
                                  unpublishing: unpublishing)
        published_status = edition.status

        status = described_class.call(revision, whitehall_edition, user_ids, edition: edition)

        expect(status.details).to be_a(Withdrawal)
        expect(status.details.published_status).to eq(published_status)
        expect(status.details.withdrawn_at.rfc3339).to eq(unpublishing["created_at"])
        expect(status.details.public_explanation).to eq(unpublishing["explanation"])
      end
    end
  end
end
