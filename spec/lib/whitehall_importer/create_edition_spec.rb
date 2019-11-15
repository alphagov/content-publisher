# frozen_string_literal: true

RSpec.describe WhitehallImporter::CreateEdition do
  include FixturesHelper

  describe "#call" do
    let(:whitehall_document) { whitehall_export_with_one_edition }
    let(:whitehall_edition) { whitehall_export_with_one_edition["editions"].first }
    let(:document) { create(:document, imported_from: "whitehall") }
    let(:user_ids) { { 1 => create(:user).id } }


    it "sets the correct states when Whitehall document state is 'published'" do
      whitehall_edition["state"] = "published"
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "published",
        "whodunnit" => 1,
      }

      WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      ).call

      expect(Edition.last.status).to be_published
      expect(Edition.last).to be_live
    end

    it "can set minor update type" do
      whitehall_edition["minor_change"] = true

      WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      ).call

      expect(Edition.last.update_type).to eq("minor")
    end

    it "sets the correct states when Whitehall document is force published" do
      whitehall_edition["state"] = "published"
      whitehall_edition["force_published"] = true
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "published",
        "whodunnit" => 1,
      }
      WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      ).call

      expect(Edition.last.status).to be_published_but_needs_2i
      expect(Edition.last).to be_live
    end

    it "sets the correct states when Whitehall document state is 'rejected'" do
      whitehall_edition["state"] = "rejected"
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "rejected",
        "whodunnit" => 1,
      }
      WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      ).call

      expect(Edition.last.status).to be_submitted_for_review
      expect(Edition.last).not_to be_live
    end

    it "sets the correct states when Whitehall document state is 'submitted'" do
      whitehall_edition["state"] = "submitted"
      whitehall_edition["revision_history"] << {
        "event" => "update",
        "state" => "submitted",
        "whodunnit" => 1,
      }
      WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      ).call

      expect(Edition.last.status).to be_submitted_for_review
      expect(Edition.last).not_to be_live
    end

    it "raises AbortImportError when edition has an unsupported state" do
      whitehall_edition["state"] = "not_supported"
      create_edition = WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      )

      expect { create_edition.call }.to raise_error(WhitehallImporter::AbortImportError)
    end

    it "raises AbortImportError when revision history is missing for state" do
      whitehall_edition["state"] = "published"
      create_edition = WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      )

      expect { create_edition.call }.to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets the created_at datetime of the document state" do
      whitehall_edition["revision_history"][0].merge!("created_at" => 3.days.ago)

      WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      ).call

      imported_created_at = whitehall_edition["revision_history"][0]["created_at"]

      expect(Edition.last.status.created_at).to be_within(1.second).of imported_created_at
    end

    it "raises AbortImportError when edition has an unsupported locale" do
      whitehall_edition["translations"][0]["locale"] = "zz"

      create_edition = WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      )

      expect { create_edition.call }.to raise_error(WhitehallImporter::AbortImportError)
    end

    it "sets the current edition" do
      WhitehallImporter::CreateEdition.new(
        document, whitehall_document, whitehall_edition, 1, user_ids
      ).call

      expect(Edition.last.current).to be true
    end

    context "when importing a withdrawn document" do
      let(:whitehall_edition) { whitehall_export_with_one_withdrawn_edition["editions"].first }

      it "sets the correct states when Whitehall document state is withdrawn" do
        WhitehallImporter::CreateEdition.new(
          document, whitehall_document, whitehall_edition, 1, user_ids
        ).call

        expect(Status.count).to eq(2)
        expect(Status.first.state).to eq("published")
        expect(Edition.last.status).to be_withdrawn
        expect(Edition.last).to be_live
      end

      it "sets the correct states when Whitehall document state is withdrawn and was force_published" do
        whitehall_edition["force_published"] = true

        WhitehallImporter::CreateEdition.new(
          document, whitehall_document, whitehall_edition, 1, user_ids
        ).call

        expect(Status.count).to eq(2)
        expect(Status.first.state).to eq("published_but_needs_2i")
        expect(Edition.last.status).to be_withdrawn
        expect(Edition.last).to be_live
      end

      it "sets the created_by_id of each status if more than one state needs to be recorded" do
        user_ids = {
          1 => create(:user).id,
          2 => create(:user).id,
          3 => create(:user).id,
        }

        WhitehallImporter::CreateEdition.new(
          document, whitehall_document, whitehall_edition, 1, user_ids
        ).call

        expect(Status.first.created_by_id).to eq(user_ids[2])
        expect(Edition.last.status.created_by_id).to eq(user_ids[3])
      end

      it "raises AbortImportError when revision history cannot be found for state" do
        whitehall_edition["revision_history"].delete_at(1)
        create_edition = WhitehallImporter::CreateEdition.new(
          document, whitehall_document, whitehall_edition, 1, user_ids
        )

        expect { create_edition.call }.to raise_error(WhitehallImporter::AbortImportError)
      end

      it "sets the created_at datetime of the initial and current document states" do
        WhitehallImporter::CreateEdition.new(
          document, whitehall_document, whitehall_edition, 1, user_ids
        ).call

        expect(Status.first.created_at).to eq(whitehall_edition["revision_history"][1]["created_at"])
        expect(Edition.last.status.created_at).to eq(whitehall_edition["revision_history"][2]["created_at"])
      end

      it "raises AbortImportError when document is withdrawn but has no unpublishing details" do
        whitehall_edition["unpublishing"] = nil
        create_edition = WhitehallImporter::CreateEdition.new(
          document, whitehall_document, whitehall_edition, 1, user_ids
        )

        expect { create_edition.call }.to raise_error(WhitehallImporter::AbortImportError)
      end

      it "sets the Withdrawal details for a withdrawn document" do
        WhitehallImporter::CreateEdition.new(
          document, whitehall_document, whitehall_edition, 1, user_ids
        ).call

        details = Edition.last.status.details

        expect(details.published_status_id).to eq(Status.first.id)
        expect(details.public_explanation).to eq(whitehall_edition["unpublishing"]["explanation"])
        expect(details.withdrawn_at).to eq(whitehall_edition["unpublishing"]["created_at"])
      end
    end
  end
end
