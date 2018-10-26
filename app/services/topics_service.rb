# frozen_string_literal: true

require "gds_api/publishing_api_v2"

class TopicsService
  GOVUK_HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"
  CACHE_OPTIONS = { expires_in: 5.minutes, race_condition_ttl: 10.seconds }.freeze

  def topics
    Rails.cache.fetch("topics", CACHE_OPTIONS) do
      all_topics = {}

      all_topics[GOVUK_HOMEPAGE_CONTENT_ID] = {
        title: "GOV.UK Homepage",
        children: level_one_topics.map { |level_one_topic| level_one_topic["content_id"] },
      }

      unroll(all_topics, level_one_topics)
      all_topics
    end
  end

private

  def unroll(all_topics, topics)
    topics.each do |topic|
      child_topics = topic.dig("links", "child_taxons").to_a
      child_topic_content_ids = child_topics.map { |child_topic| child_topic["content_id"] }

      all_topics[topic["content_id"]] = { title: topic["title"], children: child_topic_content_ids }
      unroll(all_topics, child_topics)
    end
  end

  def level_one_topics
    @level_one_topics ||= publishing_api.get_expanded_links(GOVUK_HOMEPAGE_CONTENT_ID)
      .dig("expanded_links", "level_one_taxons")

    @level_one_topics.each do |level_one_topic|
      level_one_topic_content_id = level_one_topic["content_id"]
      level_one_topic_links = publishing_api.get_expanded_links(level_one_topic_content_id)
      level_one_topic["links"] = level_one_topic_links["expanded_links"]
    end

    @level_one_topics
  end

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end
end
