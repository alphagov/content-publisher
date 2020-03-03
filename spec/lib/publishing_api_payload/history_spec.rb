RSpec.describe PublishingApiPayload::History do
  describe "#public_updated_at" do
    it "returns current time if a major change is published" do
      freeze_time do
        first_edition = build(:edition)
        second_edition = build(:edition, document: first_edition.document, update_type: "major")

        expect(described_class.new(second_edition).public_updated_at).to eq(Time.zone.now)
      end
    end

    it "returns most recent change history time if a minor change is published" do
      first_edition = build(:edition, first_published_at: "2020-02-22 11:00:00")
      second_edition = build(:edition, document: first_edition.document, update_type: "minor")

      expect(described_class.new(second_edition).public_updated_at).to eq("2020-02-22 11:00:00")
    end
  end

  describe "#first_published_at" do
    it "returns backdated date if edition is backdated" do
      edition = build(:edition, first_published_at: "2020-02-22 11:00:00", backdated_to: "2020-02-20 09:00:00")

      expect(described_class.new(edition).first_published_at).to eq("2020-02-20 09:00:00")
    end

    it "returns first published date if edition is not backdated" do
      edition = build(:edition, first_published_at: "2020-02-22 11:00:00")

      expect(described_class.new(edition).first_published_at).to eq("2020-02-22 11:00:00")
    end
  end

  describe "#change_history" do
    let(:first_edition) { build(:edition, first_published_at: "2020-02-22 11:00:00") }
    let(:first_change_note) do
      {
        note: "First published.",
        public_timestamp: "2020-02-22 11:00:00",
      }
    end

    it "appends first change note to end of history array" do
      expect(described_class.new(first_edition).change_history).to eq([first_change_note])
    end

    it "adds change note to start of array for major changes" do
      freeze_time do
        second_edition = build(:edition, document: first_edition.document, number: 2, update_type: "major", change_note: "Some changes")

        expected_change_note = {
          note: "Some changes",
          public_timestamp: Time.zone.now,
        }

        expect(described_class.new(second_edition).change_history).to eq([expected_change_note, first_change_note])
      end
    end

    it "does not add change note to start of array for minor changes" do
      second_edition = build(:edition, document: first_edition.document, number: 2, update_type: "minor", change_note: "A minor change")

      expect(described_class.new(second_edition).change_history).to eq([first_change_note])
    end

    it "returns change notes in reverse chronological order" do
      change_history = [
        {
          note: "First update",
          public_timestamp: "2020-02-23 09:00:00",
        },
        {
          note: "Third update",
          public_timestamp: "2020-02-25 21:00:00",
        },
        {
          note: "Second update",
          public_timestamp: "2020-02-24 12:00:00",
        },
      ]

      second_edition = build(:edition, document: first_edition.document, change_history: change_history)

      expected_change_notes = [
        {
          note: "Third update",
          public_timestamp: "2020-02-25 21:00:00",
        },
        {
          note: "Second update",
          public_timestamp: "2020-02-24 12:00:00",
        },
        {
          note: "First update",
          public_timestamp: "2020-02-23 09:00:00",
        },
        {
          note: "First published.",
          public_timestamp: "2020-02-22 11:00:00",
        },
      ]

      expect(described_class.new(second_edition).change_history).to eq(expected_change_notes)
    end

    it "does not include change notes set before backdating" do
      change_history = [
        {
          note: "Update before backdating",
          public_timestamp: "2020-02-18 08:00:00",
        },
      ]

      edition = build(:edition, :published, change_history: change_history, backdated_to: "2020-02-22 11:00:00")

      expect(described_class.new(edition).change_history).to eq([first_change_note])
    end
  end
end
