# frozen_string_literal: true

require "gds_api/publishing_api_v2"

class LinkablesService
  attr_reader :document_type

  def initialize(document_type)
    @document_type = document_type
  end

  def select_options
    linkables.map { |content| [content["title"], content["content_id"]] }
  end

  def by_content_id(content_id)
    linkables.find { |l| l["content_id"] == content_id }
  end

  def linkables
    @linkables ||= publishing_api.get_linkables(document_type: document_type).to_hash
  end

private

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end
end
