# frozen_string_literal: true

RSpec.describe WhitehallImporter::EditionHistory do
  describe "#state_event" do
    it "returns the event associated with the state" do
      revision_history = [build(:revision_history_event)]
      event = described_class.new(revision_history).state_event("draft")

      expect(event).to eq(revision_history.first)
    end

    it "aborts if the edition is missing a state event" do
      revision_history = [build(:revision_history_event)]

      expect { described_class.new(revision_history).state_event("published") }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  describe "#create_event" do
    it "returns the create event of the edition" do
      revision_history = [build(:revision_history_event)]
      event = described_class.new(revision_history).create_event

      expect(event).to eq(revision_history.first)
    end

    it "aborts if the edition is missing the create event" do
      revision_history = []

      expect { described_class.new(revision_history).create_event }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  describe "#last_unpublishing_event" do
    it "returns the last publishing event of the edition" do
      revision_history = [
        build(:revision_history_event),
        build(:revision_history_event, event: "update", state: "published"),
        build(:revision_history_event, event: "update", state: "draft"),
      ]
      event = described_class.new(revision_history).last_unpublishing_event

      expect(event).to eq(revision_history.last)
    end

    it "aborts if the edition is missing the unpublishing event" do
      revision_history = []

      expect { described_class.new(revision_history).last_unpublishing_event }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  describe "#next_event" do
    it "returns the next event" do
      revision_history = [
        build(:revision_history_event),
        build(:revision_history_event, event: "update", state: "published"),
      ]
      event = described_class.new(revision_history).next_event(revision_history.first)

      expect(event).to eq(revision_history.last)
    end

    it "aborts if the edition is missing a next event" do
      revision_history = [build(:revision_history_event)]

      expect { described_class.new(revision_history).next_event(revision_history.first) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  describe "#edited_after_unpublishing?" do
    it "returns true if second to last event isn't published" do
      revision_history = [
        build(:revision_history_event),
        build(:revision_history_event),
      ]
      edited_boolean = described_class.new(revision_history).edited_after_unpublishing?

      expect(edited_boolean).to be_truthy
    end

    it "returns false if second to last event doesn't exist" do
      revision_history = [build(:revision_history_event)]
      edited_boolean = described_class.new(revision_history).edited_after_unpublishing?

      expect(edited_boolean).to be_falsey
    end

    it "returns false if second to last event is published" do
      revision_history = [
        build(:revision_history_event),
        build(:revision_history_event, event: "update", state: "published"),
        build(:revision_history_event, event: "update", state: "draft"),
      ]
      edited_boolean = described_class.new(revision_history).edited_after_unpublishing?

      expect(edited_boolean).to be_falsey
    end
  end
end
