# frozen_string_literal: true

RSpec.describe WhitehallImporter::MigrateState do
  describe "#call" do
    it "sets the correct state when Whitehall document state is 'draft'" do
      state = described_class.call("draft", false)
      expect(state).to eq("draft")
    end

    it "sets the correct state when Whitehall document state is 'published'" do
      state = described_class.call("published", false)
      expect(state).to eq("published")
    end

    it "sets the correct state when Whitehall document is force published" do
      state = described_class.call("published", true)
      expect(state).to eq("published_but_needs_2i")
    end

    it "sets the correct state when Whitehall document state is 'rejected'" do
      state = described_class.call("rejected", false)
      expect(state).to eq("submitted_for_review")
    end

    it "sets the correct state when Whitehall document state is 'submitted'" do
      state = described_class.call("submitted", false)
      expect(state).to eq("submitted_for_review")
    end

    it "sets the correct state when Whitehall document state is 'superseded'" do
      state = described_class.call("superseded", false)
      expect(state).to eq("superseded")
    end

    it "raises WhitehallImporter::AbortImportError when edition has an unsupported state" do
      expect { described_class.call("brexit-state", false) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end
end
