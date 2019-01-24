# frozen_string_literal: true

RSpec.describe Edition do
  include ActiveSupport::Testing::TimeHelpers

  describe ".create_initial" do
    let(:document) { build(:document) }
    let(:user) { build(:user) }

    it "creates a current edition" do
      edition = Edition.create_initial(document, user)

      expect(edition).to be_a(Edition)
      expect(edition.created_by).to eq(user)
      expect(edition.current).to be true
      expect(edition.number).to be 1
    end

    it "has a revision" do
      edition = Edition.create_initial(document, user)

      expect(edition.revision).to be_a(Revision)
      expect(edition.created_by).to eq(user)
    end

    it "has a status which is draft" do
      edition = Edition.create_initial(document, user)

      expect(edition.status).to be_a(Status)
      expect(edition.status).to be_draft
    end
  end

  describe ".create_next_edition" do
    let(:user) { build(:user) }

    it "creates a draft edition with next edition number" do
      preceding = create(:edition, number: 5, current: false)

      edition = Edition.create_next_edition(preceding, user)

      expect(edition).to be_a(Edition)
      expect(edition).to be_draft
      expect(edition.number).to be 6
    end

    it "resets the change note and update type" do
      preceding = create(:edition,
                         change_note: "Changes",
                         update_type: :minor,
                         current: false)

      edition = Edition.create_next_edition(preceding, user)

      expect(edition.change_note).to be_empty
      expect(edition.update_type).to eq("major")
    end
  end

  describe "#resume_discarded" do
    let(:live_edition) { create(:edition, :published, current: false) }
    let(:user) { build(:user) }

    it "sets the edition to be a draft" do
      edition = create(:edition,
                       state: :discarded,
                       document: live_edition.document)

      edition.resume_discarded(live_edition, user)

      expect(edition).to be_draft
    end

    it "resets the change note and update type" do
      edition = create(:edition,
                       state: :discarded,
                       document: live_edition.document,
                       change_note: "Changes",
                       update_type: :minor)

      edition.resume_discarded(live_edition, user)

      expect(edition.change_note).to be_empty
      expect(edition.update_type).to eq("major")
    end
  end

  describe "#assign_status" do
    let(:edition) { build(:edition) }
    let(:user) { build(:user) }

    it "sets a status for a user" do
      edition.assign_status(:submitted_for_review, user)

      expect(edition.status).to be_submitted_for_review
      expect(edition.status.created_by).to eq(user)
    end

    it "does not save the edition" do
      edition.assign_status(:submitted_for_review, user)

      expect(edition).to be_new_record
    end

    it "returns the edition" do
      returned = edition.assign_status(:submitted_for_review, user)

      expect(returned).to be(edition)
    end

    it "updates last edited" do
      travel_to(Time.current) do
        edition.assign_status(:submitted_for_review, user)

        expect(edition.last_edited_at).to eq(Time.current)
        expect(edition.last_edited_by).to eq(user)
      end
    end

    it "preserves last edited when specified" do
      travel_to(Time.current) do
        edition.last_edited_at = 10.days.ago
        edition.last_edited_by = build(:user)

        edition.assign_status(:submitted_for_review,
                              user,
                              update_last_edited: false)

        expect(edition.last_edited_at).not_to eq(Time.current)
        expect(edition.last_edited_at).to eq(10.days.ago)
        expect(edition.last_edited_by).not_to eq(user)
      end
    end

    it "can set details on the status" do
      removal = build(:removal)
      edition.assign_status(:removed, user, status_details: removal)

      expect(edition.status.details).to eq(removal)
    end
  end

  describe "#assign_revision" do
    let(:edition) { build(:edition) }
    let(:revision) { build(:revision, document: edition.document) }
    let(:user) { build(:user) }

    it "sets the revision and updates last edited" do
      travel_to(Time.current) do
        edition.assign_revision(revision, user)

        expect(edition.revision).to eq(revision)
        expect(edition.last_edited_by).to eq(user)
        expect(edition.last_edited_at).to eq(Time.current)
      end
    end

    it "does not save the edition" do
      edition.assign_revision(revision, user)

      expect(edition).to be_new_record
    end

    it "returns the edition" do
      returned = edition.assign_revision(revision, user)

      expect(returned).to be(edition)
    end
  end
end
