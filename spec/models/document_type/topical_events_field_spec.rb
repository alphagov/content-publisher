RSpec.describe DocumentType::TopicalEventsField do
  describe "#payload" do
    it "returns a hash with 'topical_events'" do
      topical_event_ids = [SecureRandom.uuid, SecureRandom.uuid]
      edition = build(:edition, tags: { topical_events: topical_event_ids })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:topical_events]).to eq(topical_event_ids)
    end
  end

  describe "#updater_params" do
    it "returns a hash of the topical_events" do
      edition = build :edition
      params = ActionController::Parameters.new(topical_events: %w[some_topical_event_id])
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(topical_events: %w[some_topical_event_id])
    end

    it "disallows incorect data" do
      edition = build :edition
      params = ActionController::Parameters.new(organisations: nil)
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to be_empty
    end
  end
end
