# frozen_string_literal: true

RSpec.describe WhitehallImporter::EditionHistory do
  describe "#state_event" do
    it "returns the event associated with the state" do
      whitehall_edition = build(:whitehall_export_edition)
      event = described_class.state_event(whitehall_edition)

      expect(event).to eq(whitehall_edition["revision_history"].first)
    end

    it "aborts if the edition is missing a state event" do
      whitehall_edition = build(:whitehall_export_edition, state: "published")

      expect { described_class.state_event(whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  describe "#create_event" do
    it "returns the create event of the edition" do
      whitehall_edition = build(:whitehall_export_edition)
      event = described_class.create_event(whitehall_edition)

      expect(event).to eq(whitehall_edition["revision_history"].first)
    end

    it "aborts if the edition is missing the create event" do
      whitehall_edition = build(:whitehall_export_edition, revision_history: [])

      expect { described_class.create_event(whitehall_edition) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end
end
