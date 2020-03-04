RSpec.describe MetadataRevision do
  describe "validating change_history" do
    def change_history_item(id: SecureRandom.uuid,
                            note: "Note",
                            public_timestamp: Time.zone.today.rfc3339)
      { "id" => id, "note" => note, "public_timestamp" => public_timestamp }
    end

    it "validates when the change history is valid" do
      change_history = [
        change_history_item(public_timestamp: Time.zone.today.rfc3339),
        change_history_item(public_timestamp: Time.zone.yesterday.rfc3339),
      ]

      expect(build(:metadata_revision, change_history: change_history)).to be_valid
    end

    it "copes when two items have the same public_timestamp" do
      change_history = [
        change_history_item(public_timestamp: Time.zone.yesterday.rfc3339),
        change_history_item(public_timestamp: Time.zone.yesterday.rfc3339),
      ]

      expect(build(:metadata_revision, change_history: change_history)).to be_valid
    end

    it "fails validation if 'id' is missing" do
      change_history = [change_history_item.except("id")]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with invalid keys")
    end

    it "fails validation if 'note' is missing" do
      change_history = [change_history_item.except("note")]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with invalid keys")
    end

    it "fails validation if 'public_timestamp' is missing" do
      change_history = [change_history_item.except("public_timestamp")]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with invalid keys")
    end

    it "fails validation if the 'id' is not a valid UUID" do
      change_history = [change_history_item(id: "1234567-123-123-123-01234567890")]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with a non UUID id")
    end

    it "fails validation if 'public_timestamp' is not a valid date" do
      change_history = [change_history_item(public_timestamp: "20201-13-32 29:61:61")]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with an invalid timestamp")
    end

    it "fails validation when notes are not in reverse chronological order" do
      change_history = [
        change_history_item(public_timestamp: Time.zone.yesterday.rfc3339),
        change_history_item(public_timestamp: Time.zone.today.rfc3339),
      ]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history is not in a reverse chronological ordering")
    end
  end
end
