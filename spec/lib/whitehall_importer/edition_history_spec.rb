# frozen_string_literal: true

RSpec.describe WhitehallImporter::EditionHistory do
  describe "#state_event" do
    it "returns the event associated with the state" do
      revision_history = build(:whitehall_export_edition)["revision_history"]
      event = described_class.new(revision_history).state_event("draft")

      expect(event).to eq(revision_history.first)
    end

    it "aborts if the edition is missing a state event" do
      revision_history = build(:whitehall_export_edition)["revision_history"]

      expect { described_class.new(revision_history).state_event("published") }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  describe "#create_event" do
    it "returns the create event of the edition" do
      revision_history = build(:whitehall_export_edition)["revision_history"]
      event = described_class.new(revision_history).create_event

      expect(event).to eq(revision_history.first)
    end

    it "aborts if the edition is missing the create event" do
      revision_history = build(:whitehall_export_edition, revision_history: [])["revision_history"]

      expect { described_class.new(revision_history).create_event }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end
end
