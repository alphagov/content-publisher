# frozen_string_literal: true

require "gds_api/publishing_api_v2"

class TopicsService
  GOVUK_HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"
  CACHE_OPTIONS = { expires_in: 5.minutes, race_condition_ttl: 10.seconds }.freeze

  def tree
    Rails.cache.fetch("topics", CACHE_OPTIONS) do
      level_one_topics.map do |level_one_topic|
        level_one_topic["links"] = lower_level_topics(level_one_topic)
        unroll(level_one_topic)
      end
    end
  end

private

  def unroll(topic)
    children = topic.dig("links", "child_taxons")
      .to_a
      .map { |child_topic| unroll(child_topic) }

    { title: topic["title"], children: children }
  end

  def lower_level_topics(level_one_topic)
    publishing_api.get_expanded_links(level_one_topic["content_id"])
      .dig("expanded_links")
  end

  def level_one_topics
    publishing_api.get_expanded_links(GOVUK_HOMEPAGE_CONTENT_ID)
      .dig("expanded_links", "level_one_taxons")
      .to_a
  end

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      timeout: 60,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end
end
