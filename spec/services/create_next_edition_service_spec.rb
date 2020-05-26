RSpec.describe CreateNextEditionService do
  describe ".call" do
    let(:user) { create :user }

    before do
      populate_default_government_bulk_data
    end

    it "aborts if the current edition isn't live" do
      current_edition = create(:edition, live: false)

      expect { described_class.call(current_edition: current_edition, user: user) }
        .to raise_error("Can only create a next edition from a live edition")
    end

    it "returns a new current edition" do
      current_edition = create(:edition, :published, number: 2)

      next_edition = described_class.call(current_edition: current_edition,
                                          user: user)

      expect(current_edition).not_to be_current
      expect(next_edition).to be_current
    end

    it "updates the edition number of the new current edition" do
      current_edition = create(:edition, :published, number: 2)

      next_edition = described_class.call(current_edition: current_edition,
                                          user: user)

      expect(next_edition.number).to eq 3
      expect(next_edition.created_by).to eq user
    end

    it "returns a draft edition" do
      current_edition = create(:edition, :published)

      next_edition = described_class.call(current_edition: current_edition,
                                          user: user)

      expect(next_edition).to be_draft
    end

    it "resets change_note, update_type and propoposed_publish_time values" do
      current_edition = create(:edition,
                               :published,
                               change_note: "note",
                               update_type: "minor",
                               proposed_publish_time: Time.zone.now)

      next_edition = described_class.call(current_edition: current_edition,
                                          user: user)

      expect(next_edition.change_note).to be_empty
      expect(next_edition.update_type).to eq("major")
      expect(next_edition.proposed_publish_time).to be_nil
    end

    it "appends the change note details when there is a change note and a major change" do
      current_edition = create(:edition,
                               :published,
                               number: 2,
                               published_at: Date.yesterday.noon,
                               change_note: "note",
                               update_type: "major")

      next_edition = described_class.call(current_edition: current_edition,
                                          user: user)

      expect(next_edition.change_history.first).to match a_hash_including(
        "note" => "note",
        "public_timestamp" => Date.yesterday.noon.rfc3339,
      )
    end

    it "does not update the change history when the current edition is not a major change" do
      current_edition = create(:edition,
                               :published,
                               number: 2,
                               published_at: Date.yesterday.noon,
                               change_note: "note",
                               update_type: "minor")

      next_edition = described_class.call(current_edition: current_edition,
                                          user: user)

      expect(next_edition.change_history).to eq(current_edition.change_history)
    end

    it "does not update the change history when the current edition lacks a change note" do
      current_edition = create(:edition,
                               :published,
                               number: 2,
                               change_note: nil)

      next_edition = described_class.call(current_edition: current_edition,
                                          user: user)

      expect(next_edition.change_history).to be_empty
    end

    context "when the current edition is the first edition" do
      it "doesn't append the change note details" do
        current_edition = create(:edition,
                                 :published,
                                 change_note: "note")

        next_edition = described_class.call(current_edition: current_edition,
                                            user: user)

        expect(next_edition.change_history).to eq(current_edition.change_history)
      end
    end

    context "when given a discarded edition" do
      let(:live_edition) { create(:edition, :published) }
      let(:params) { { document: live_edition.document.to_param } }

      let!(:discarded_edition) do
        create(:edition,
               state: "discarded",
               current: false,
               document: live_edition.document)
      end

      it "resumes the edition" do
        next_edition = described_class.call(current_edition: live_edition,
                                            user: user,
                                            discarded_edition: discarded_edition)

        expect(next_edition.number).to eq discarded_edition.number
        expect(next_edition).to eq discarded_edition.reload
      end

      it "updates the state of the discarded edition" do
        described_class.call(current_edition: live_edition,
                             user: user,
                             discarded_edition: discarded_edition)

        expect(discarded_edition).to be_draft
      end
    end
  end
end
