RSpec.describe DocumentType::TopicalEventsField do
  describe "#payload" do
    it "returns a hash with 'topical_events'" do
      topical_event_ids = [SecureRandom.uuid, SecureRandom.uuid]
      edition = build(:edition, tags: { topical_events: topical_event_ids })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:topical_events]).to eq(topical_event_ids)
    end
  end
end
