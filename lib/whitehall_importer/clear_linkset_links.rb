module WhitehallImporter
  class ClearLinksetLinks
    attr_reader :content_id

    def self.call(...)
      new(...).call
    end

    def initialize(content_id)
      @content_id = content_id
    end

    def call
      GdsApi.publishing_api.patch_links(
        content_id,
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
      )
    end
  end
end
