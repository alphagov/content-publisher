# frozen_string_literal: true

require "gds_api/publishing_api_v2"

class LinkablesService
  CACHE_OPTIONS = { expires_in: 5.minutes, race_condition_ttl: 10.seconds }.freeze

  attr_reader :document_type

  def initialize(document_type)
    @document_type = document_type
  end

  def select_options
    linkables.map { |content| [content["internal_name"], content["content_id"]] }
      .sort_by { |option| option[0].downcase }
  end

  def by_content_id(content_id)
    linkables.find { |l| l["content_id"] == content_id }
  end

private

  def linkables
    # Maybe we'll need to go further with this a la:
    # https://github.com/alphagov/whitehall/blob/fc62edcd5a9b1ba8bfb22911f69f128083535127/app/models/policy.rb#L45-L58
    @linkables ||= Rails.cache.fetch("linkables.#{document_type}", CACHE_OPTIONS) do
      publishing_api.get_linkables(document_type: document_type).to_hash
    end
  end

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      timeout: 1,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end
end
