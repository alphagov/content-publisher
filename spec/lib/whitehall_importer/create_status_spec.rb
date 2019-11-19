# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateStatus do
  include FixturesHelper

  describe ".call" do
    let(:whitehall_edition) { whitehall_export_with_one_edition["editions"].first }
    let(:user_ids) { { 1 => create(:user).id } }
    let(:revision) { create(:revision) }

    it "sets the correct states when Whitehall document state is 'published'" do
      whitehall_edition["state"] = "published"
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "published",
        "whodunnit" => 1,
      }

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status.state).to eq("published")
    end

    it "sets the correct states when Whitehall document is force published" do
      whitehall_edition["state"] = "published"
      whitehall_edition["force_published"] = true
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "published",
        "whodunnit" => 1,
      }

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status.state).to eq("published_but_needs_2i")
    end

    it "sets the correct states when Whitehall document state is 'rejected'" do
      whitehall_edition["state"] = "rejected"
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "rejected",
        "whodunnit" => 1,
      }

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status.state).to eq("submitted_for_review")
    end

    it "sets the correct states when Whitehall document state is 'submitted'" do
      whitehall_edition["state"] = "submitted"
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "submitted",
        "whodunnit" => 1,
      }

      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status.state).to eq("submitted_for_review")
    end

    it "raises WhitehallImporter::AbortImportError when revision history is missing for state" do
      whitehall_edition["state"] = "published"

      expect { described_class.call(revision, whitehall_edition, user_ids) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets the created_at datetime of the document state" do
      whitehall_edition["revision_history"][0].merge!("created_at" => 3.days.ago)

      status = described_class.call(revision, whitehall_edition, user_ids)

      imported_created_at = whitehall_edition["revision_history"][0]["created_at"]

      expect(status.created_at).to be_within(1.second).of imported_created_at
    end

    it "sets the created_by_id of the document state" do
      status = described_class.call(revision, whitehall_edition, user_ids)

      expect(status.created_by_id).to eq(user_ids[1])
    end

    it "raises WhitehallImporter::AbortImportError when edition has an unsupported state" do
      whitehall_edition["state"] = "not_supported"
      expect { described_class.call(revision, whitehall_edition, user_ids) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end

    it "allows the default state to be overwritten by a another valid whitehall state" do
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "superseded",
        "whodunnit" => 1,
      }

      status = described_class.call(
        revision, whitehall_edition, user_ids, whitehall_edition_state: "superseded"
      )

      expect(status.state).to eq("superseded")
    end

    context "withdrawn documents" do
      let(:whitehall_edition) { whitehall_export_with_one_withdrawn_edition["editions"].first }
      let(:edition) { create(:edition, :published) }

      it "raises WhitehallImporter::AbortImportError when document is withdrawn but has no unpublishing details" do
        whitehall_edition["unpublishing"] = nil

        expect { described_class.call(revision, whitehall_edition, user_ids, edition: edition) }
          .to raise_error(WhitehallImporter::AbortImportError)
      end

      it "sets the Withdrawal details for a withdrawn document" do
        status = described_class.call(revision, whitehall_edition, user_ids, edition: edition)

        expect(status.details.published_status_id).to eq(edition.status.id)
        expect(status.details.public_explanation).to eq(whitehall_edition["unpublishing"]["explanation"])
        expect(status.details.withdrawn_at).to eq(whitehall_edition["unpublishing"]["created_at"])
      end
    end
  end
end
