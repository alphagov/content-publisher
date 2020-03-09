RSpec.describe DocumentType::WorldLocationsField do
  describe "#payload" do
    it "returns a hash with 'world_locations'" do
      world_location_ids = [SecureRandom.uuid, SecureRandom.uuid]
      edition = build(:edition, tags: { world_locations: world_location_ids })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:world_locations]).to eq(world_location_ids)
    end
  end

  describe "#updater_params" do
    it "returns a hash of the world_locations" do
      edition = build :edition
      params = ActionController::Parameters.new(world_locations: %w[some_world_location_id])
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(world_locations: %w[some_world_location_id])
    end
  end
end
