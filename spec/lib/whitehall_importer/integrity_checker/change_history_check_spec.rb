RSpec.describe WhitehallImporter::IntegrityChecker::ChangeHistoryCheck do
  describe "#match?" do
    let(:published_edition) { create(:edition, :published) }

    it "returns true if the proposed change history matches the Publishing API history for a live edition" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)
      publishing_api_change_history = change_note("First published.", Date.yesterday.noon)

      integrity_check = described_class.new(
        published_edition,
        proposed_change_history,
        publishing_api_change_history,
      )
      expect(integrity_check.match?).to be true
    end

    it "returns true if proposed change history has a 'First published' change note and Publishing API has no change history" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)
      integrity_check = described_class.new(published_edition, proposed_change_history, [])

      expect(integrity_check.match?).to be true
    end

    it "returns true for an edition with a major change & change_note which isn't live" do
      draft_edition = create(:edition, change_note: "Major draft change note")
      proposed_change_history = change_note("Major draft change note.", Date.yesterday.end_of_day) +
        change_note("First published.", Date.yesterday.noon)
      publishing_api_change_history = change_note("First published.", Date.yesterday.noon)

      integrity_check = described_class.new(draft_edition, proposed_change_history, publishing_api_change_history)
      expect(integrity_check.match?).to be true
    end

    it "returns true for an edition with a minor change which isn't live" do
      draft_edition = create(:edition, number: 2, update_type: "minor")
      proposed_change_history = change_note("First published.", Date.yesterday.noon)
      publishing_api_change_history = change_note("First published.", Date.yesterday.noon)

      integrity_check = described_class.new(draft_edition, proposed_change_history, publishing_api_change_history)
      expect(integrity_check.match?).to be true
    end

    it "returns true if first published timestamps are sufficiently similar" do
      proposed_change_history = change_note("First published.", Time.zone.now.beginning_of_minute)
      publishing_api_change_history = change_note("First published.", Time.zone.now)

      integrity_check = described_class.new(
        published_edition,
        proposed_change_history,
        publishing_api_change_history,
      )
      expect(integrity_check.match?).to be true
    end

    it "returns false if length of change history does not match" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)

      publishing_api_change_history = change_note("First published.", Date.yesterday.noon) +
        change_note("Updated", Time.zone.now)

      integrity_check = described_class.new(
        published_edition,
        proposed_change_history,
        publishing_api_change_history,
      )
      expect(integrity_check.match?).to be false
    end

    it "returns false if notes do not match" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)

      publishing_api_change_history = change_note("Updated", Date.yesterday.noon)

      integrity_check = described_class.new(
        published_edition,
        proposed_change_history,
        publishing_api_change_history,
      )
      expect(integrity_check.match?).to be false
    end

    it "returns false if public_timestamp does not match" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)

      publishing_api_change_history = change_note("First published.", Time.zone.now)

      integrity_check = described_class.new(
        published_edition,
        proposed_change_history,
        publishing_api_change_history,
      )
      expect(integrity_check.match?).to be false
    end
  end

  def change_note(note, timestamp)
    [{ "note" => note, "public_timestamp" => timestamp.rfc3339 }]
  end
end
