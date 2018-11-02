# frozen_string_literal: true

require "gds_api/publishing_api_v2"

class TopicsService
  GOVUK_HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"
  CACHE_OPTIONS = { expires_in: 5.minutes, race_condition_ttl: 10.seconds }.freeze
  TOPIC_INDEX_TIMEOUT = 4.seconds

  def topic_index
    Rails.cache.fetch("topics", CACHE_OPTIONS) do
      index = {}

      index[GOVUK_HOMEPAGE_CONTENT_ID] = {
        title: "GOV.UK Homepage",
        children: level_one_topics.map { |level_one_topic| level_one_topic["content_id"] },
      }

      unroll(index, level_one_topics, GOVUK_HOMEPAGE_CONTENT_ID)
      index
    end
  end

  def patch_topics(document, topics, version)
    publishing_api.patch_links(document.content_id, links: { taxons: topics }, previous_version: version)
  end

  def topics_for_document(document)
    links = publishing_api.get_links(document.content_id)
    topic_content_ids = links.dig("links", "taxons").to_a
    [topic_content_ids, links["version"]]
  end

  def topic_breadcrumb(topic_content_id)
    topic = topic_index[topic_content_id]
    parent = topic[:parent]
    parent ? [topic] + topic_breadcrumb(parent) : [topic]
  end

private

  def unroll(index, topics, parent_topic)
    topics.each do |topic|
      child_topics = topic.dig("links", "child_taxons").to_a
      child_topic_content_ids = child_topics.map { |child_topic| child_topic["content_id"] }

      index[topic["content_id"]] = {
        title: topic["title"],
        children: child_topic_content_ids,
        parent: parent_topic["content_id"],
      }
      unroll(index, child_topics, topic)
    end
  end

  def level_one_topics
    start_time = Time.zone.now

    @level_one_topics ||= publishing_api.get_expanded_links(GOVUK_HOMEPAGE_CONTENT_ID)
      .dig("expanded_links", "level_one_taxons")

    @level_one_topics.each do |level_one_topic|
      raise GdsApi::TimedOutException.new if Time.zone.now - start_time > TOPIC_INDEX_TIMEOUT
      level_one_topic_content_id = level_one_topic["content_id"]

      level_one_topic_links = publishing_api.get_expanded_links(level_one_topic_content_id)
      level_one_topic["links"] = level_one_topic_links["expanded_links"]
    end

    @level_one_topics
  end

  def publishing_api
    GdsApi.publishing_api_v2(timeout: 1)
  end
end
