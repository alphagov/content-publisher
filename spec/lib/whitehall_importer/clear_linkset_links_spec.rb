RSpec.describe WhitehallImporter::ClearLinksetLinks do
  describe "#call" do
    before do
      stub_any_publishing_api_patch_links
    end

    it "clears all linkset links except topics and taxons" do
      content_id = SecureRandom.uuid
      linkset_params = {
        links: {
          related_policies: [],
          ministers: [],
          topical_events: [],
          world_locations: [],
          worldwide_organisations: [],
          roles: [],
          people: [],
          primary_publishing_organisation: [],
          organisations: [],
          government: [],
        },
      }

      request = stub_publishing_api_patch_links(content_id, linkset_params)
      described_class.call(content_id)

      expect(request).to have_been_requested
    end
  end
end
