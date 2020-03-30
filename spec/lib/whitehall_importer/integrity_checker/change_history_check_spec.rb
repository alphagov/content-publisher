RSpec.describe WhitehallImporter::IntegrityChecker::ChangeHistoryCheck do
  describe "#match?" do
    it "returns true if the proposed change history matches the Publishing API history for a non-draft edition" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)
      publishing_api_change_history = change_note("First published.", Date.yesterday.noon)

      integrity_check = described_class.new(
        proposed_change_history,
        publishing_api_change_history,
        create(:edition, :published),
      )
      expect(integrity_check.match?).to be true
    end

    it "returns true if the proposed change history matches for a draft edition with mismatched time stamps for first item" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon) +
        change_note("Updated", Time.zone.now)

      publishing_api_change_history = change_note("First published.", Time.zone.now) +
        change_note("Updated", Time.zone.now)

      integrity_check = described_class.new(
        proposed_change_history,
        publishing_api_change_history,
        create(:edition),
      )
      expect(integrity_check.match?).to be true
    end

    it "returns true if proposed change history has a 'First published' change note and Publishing API has no change history" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)
      integrity_check = described_class.new(proposed_change_history,
                                            [],
                                            create(:edition))

      expect(integrity_check.match?).to be true
    end

    it "returns false if length of change history does not match" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)

      publishing_api_change_history = change_note("First published.", Date.yesterday.noon) +
        change_note("Updated", Time.zone.now)

      integrity_check = described_class.new(
        proposed_change_history,
        publishing_api_change_history,
        create(:edition, :published),
      )
      expect(integrity_check.match?).to be false
    end

    it "returns false if notes do not match" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)

      publishing_api_change_history = change_note("Updated", Date.yesterday.noon)

      integrity_check = described_class.new(
        proposed_change_history,
        publishing_api_change_history,
        create(:edition, :published),
      )
      expect(integrity_check.match?).to be false
    end

    it "returns false if public_timestamp does not match" do
      proposed_change_history = change_note("First published.", Date.yesterday.noon)

      publishing_api_change_history = change_note("First published.", Time.zone.now)

      integrity_check = described_class.new(
        proposed_change_history,
        publishing_api_change_history,
        create(:edition, :published),
      )
      expect(integrity_check.match?).to be false
    end
  end

  def change_note(note, timestamp)
    [{ "note" => note, "public_timestamp" => timestamp.rfc3339 }]
  end
end
