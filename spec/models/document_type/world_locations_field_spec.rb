RSpec.describe DocumentType::WorldLocationsField do
  describe "#payload" do
    it "returns a hash with 'world_locations'" do
      world_location_ids = [SecureRandom.uuid, SecureRandom.uuid]
      edition = build(:edition, tags: { world_locations: world_location_ids })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:world_locations]).to eq(world_location_ids)
    end
  end
end
