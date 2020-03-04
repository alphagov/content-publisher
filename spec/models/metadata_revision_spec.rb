RSpec.describe MetadataRevision do
  describe "validating change_history" do
    it "validates when the change history is valid" do
      change_history = [
        {
          "id" => SecureRandom.uuid,
          "note" => "Newest",
          "public_timestamp" => Time.zone.today.rfc3339,
        },
        {
          "id" => SecureRandom.uuid,
          "note" => "Oldest",
          "public_timestamp" => Time.zone.yesterday.rfc3339,
        },
      ]

      expect(build(:metadata_revision, change_history: change_history)).to be_valid
    end

    it "copes when two items have the same public_timestamp" do
      change_history = [
        {
          "id" => SecureRandom.uuid,
          "note" => "Note",
          "public_timestamp" => Time.zone.today.rfc3339,
        },
        {
          "id" => SecureRandom.uuid,
          "note" => "Note",
          "public_timestamp" => Time.zone.today.rfc3339,
        },
      ]

      expect(build(:metadata_revision, change_history: change_history)).to be_valid
    end

    it "fails validation if 'id' is missing" do
      change_history = [
        { "note" => "Testing", "public_timestamp" => Time.zone.today.rfc3339 },
      ]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with invalid keys")
    end

    it "fails validation if 'note' is missing" do
      id = SecureRandom.uuid
      change_history = [
        { "id" => id, "public_timestamp" => Time.zone.today.rfc3339 },
      ]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with invalid keys")
    end

    it "fails validation if 'public_timestamp' is missing" do
      id = SecureRandom.uuid
      change_history = [
        { "id" => id, "note" => "Testing" },
      ]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with invalid keys")
    end

    it "fails validation if the 'id' is not a valid UUID" do
      id = "1234567-123-123-123-01234567890"
      change_history = [
        {
          "id" => id,
          "note" => "Testing",
          "public_timestamp" => Time.zone.today.rfc3339,
        },
      ]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with a non UUID id")
    end

    it "fails validation if 'public_timestamp' is not a valid date" do
      id = SecureRandom.uuid
      change_history = [
        {
          "id" => id,
          "note" => "Testing",
          "public_timestamp" => "20201-13-32 29:61:61",
        },
      ]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history has an entry with an invalid timestamp")
    end

    it "fails validation when notes are not in reverse chronological order" do
      change_history = [
        {
          "id" => SecureRandom.uuid,
          "note" => "Oldest",
          "public_timestamp" => Time.zone.yesterday.rfc3339,
        },
        {
          "id" => SecureRandom.uuid,
          "note" => "Newest",
          "public_timestamp" => Time.zone.today.rfc3339,
        },
      ]

      expect { build(:metadata_revision, change_history: change_history).valid? }
        .to raise_error(ActiveModel::StrictValidationFailed,
                        "Change history is not in a reverse chronological ordering")
    end
  end
end
