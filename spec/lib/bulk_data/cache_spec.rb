RSpec.describe BulkData::Cache do
  describe ".write" do
    it "adds an entry that expires in 24 hours" do
      described_class.write("key", "value")
      expect(described_class.cache.read("key")).to eq("value")

      travel_to(25.hours.from_now) do
        expect(described_class.cache.read("key")).to be_nil
      end
    end

    it "sets the current time as the age, which also expires" do
      freeze_time do
        described_class.write("key", "value")
        expect(described_class.cache.read("key:created")).to eq(Time.current)
      end

      travel_to(25.hours.from_now) do
        expect(described_class.cache.read("key:created")).to be_nil
      end
    end
  end

  describe ".read" do
    it "returns a value when one exists" do
      described_class.write("key", "value")
      expect(described_class.read("key")).to eq("value")
    end

    it "raises a NoEntryError when there isn't an entry" do
      expect { described_class.read("key") }
        .to raise_error(BulkData::Cache::NoEntryError)
    end
  end

  describe ".written_at" do
    it "returns the time the entry was created" do
      time = 2.hours.ago.change(usec: 0)
      travel_to(time) { described_class.write("key", "value") }
      expect(described_class.written_at("key")).to eq(time)
    end

    it "returns nil when the entry doesn't exist" do
      expect(described_class.written_at("key")).to be_nil
    end

    it "returns nil when only the created value exists but not the actual entry" do
      described_class.cache.write("key:created", Time.current)

      expect(described_class.written_at("key")).to be_nil
    end
  end

  describe ".written_after?" do
    it "returns true if the cache was written after the time" do
      travel_to(3.minutes.ago) { described_class.write("key", "value") }
      expect(described_class.written_after?("key", 5.minutes.ago)).to be true
    end

    it "returns false if the cache was written before the time" do
      travel_to(10.minutes.ago) { described_class.write("key", "value") }
      expect(described_class.written_after?("key", 5.minutes.ago)).to be false
    end

    it "returns false if the cache entry doesn't exist" do
      expect(described_class.written_after?("key", 5.minutes.ago)).to be false
    end
  end

  describe ".delete" do
    it "deletes an entry" do
      described_class.write("key", "value")
      expect { described_class.delete("key") }
        .to change { described_class.cache.read("key") }.to(nil)
    end

    it "deletes the created value of an entry" do
      described_class.write("key", "value")
      expect { described_class.delete("key") }
        .to change { described_class.cache.read("key:created") }.to(nil)
    end
  end

  describe ".clear" do
    it "deletes all entries" do
      described_class.write("key", "value")
      described_class.write("another-key", "different value")

      expect { described_class.clear }
        .to change { described_class.cache.read("key") }.to(nil)
        .and change { described_class.cache.read("another-key") }.to(nil)
    end
  end
end
