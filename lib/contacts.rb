# frozen_string_literal: true

class Contacts
  CACHE_OPTIONS = { expires_in: 15.minutes, race_condition_ttl: 30.seconds }.freeze
  EDITION_PARAMS = {
    document_types: %w[contact].freeze,
    fields: %w[content_id locale title description details links].freeze,
    states: %w[published].freeze,
    # This will need changing when this app supports more locales
    locale: "en",
    order: "id",
    per_page: 1000,
  }.freeze

  def by_content_id(content_id)
    all_contacts.find { |contact| contact["content_id"] == content_id }
  end

  def all_by_organisation
    @all_by_organisation ||= load_contacts_by_organisation
  end

private

  def all_contacts
    @all_contacts ||= Rails.cache.fetch("all_contacts", CACHE_OPTIONS) do
      load_all_contacts
    end
  end

  def load_all_contacts
    GdsApi
      .publishing_api_v2
      .get_paged_editions(EDITION_PARAMS)
      .inject([]) { |memo, page| memo + page["results"] }
  end

  def organisation_select_options
    @organisation_select_options ||= Linkables.new("organisation").select_options
  end

  def load_contacts_by_organisation
    contacts_by_org = all_contacts.each_with_object({}) do |contact, memo|
      orgs = contact.dig("links", "organisations").to_a
      orgs.each do |content_id|
        memo[content_id] = memo[content_id].to_a + [contact]
      end
    end

    organisation_select_options.map do |(name, content_id)|
      {
        "name" => name,
        "content_id" => content_id,
        "contacts" => contacts_by_org.fetch(content_id, []),
      }
    end
  end
end
