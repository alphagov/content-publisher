# frozen_string_literal: true

RSpec.describe Edition do
  include ActiveSupport::Testing::TimeHelpers

  describe ".find_current" do
    it "finds an edition by id" do
      edition = create(:edition)

      expect(Edition.find_current(id: edition.id)).to eq(edition)
    end

    it "finds an edition by a document param" do
      edition = create(:edition)
      param = "#{edition.content_id}:#{edition.locale}"

      expect(Edition.find_current(document: param)).to eq(edition)
    end

    it "only finds a current edition" do
      edition = create(:edition, current: false)

      expect { Edition.find_current(id: edition.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".find_and_lock_current" do
    it "passes a found and locked edition to a block" do
      edition = create(:edition)
      param = "#{edition.content_id}:#{edition.locale}"

      expect(Edition).to receive(:lock).and_call_original
      expect { |block| Edition.find_and_lock_current(document: param, &block) }
        .to yield_with_args(edition)
    end
  end

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

    it "resets the change note, update type and proposed publish time" do
      preceding = create(:edition,
                         change_note: "Changes",
                         update_type: :minor,
                         current: false,
                         proposed_publish_time: Time.zone.now)

      edition = Edition.create_next_edition(preceding, user)

      expect(edition.change_note).to be_empty
      expect(edition.update_type).to eq("major")
      expect(edition.proposed_publish_time).to be_nil
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
    let(:revision) { build(:revision) }
    let(:user) { build(:user) }

    context "when an edition is live" do
      it "raises an error" do
        edition = build(:edition, :published)

        expect { edition.assign_revision(revision, user) }
          .to raise_error(RuntimeError, "cannot update revision on a live edition")
      end
    end

    context "when an edition is not live" do
      let(:edition) { build(:edition) }

      it "sets the revision and updates last edited" do
        travel_to(Time.current) do
          edition.assign_revision(revision, user)
          expect(edition.revision).to eq(revision)
          expect(edition.last_edited_by).to eq(user)
          expect(edition.last_edited_at).to eq(Time.current)
          expect(edition).to be_new_record
        end
      end

      it "returns the edition" do
        returned = edition.assign_revision(revision, user)
        expect(returned).to be(edition)
      end
    end
  end
end
