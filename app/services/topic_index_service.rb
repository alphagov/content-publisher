# frozen_string_literal: true

class TopicIndexService
  GOVUK_HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"
  CACHE_OPTIONS = { expires_in: 5.minutes, race_condition_ttl: 10.seconds }.freeze
  TOPIC_INDEX_TIMEOUT = 10.seconds

  def lookup(topic_content_id)
    index[topic_content_id]
  end

private

  def index
    @index ||= fetch_topic_index
  end

  def fetch_topic_index
    Rails.cache.fetch("topic_index", CACHE_OPTIONS) do
      govuk_homepage_topic = {
        content_id: GOVUK_HOMEPAGE_CONTENT_ID,
        title: "GOV.UK Homepage",
        child_content_ids: raw_level_one_topics.map { |raw_topic| raw_topic["content_id"] },
        legacy_topic_content_ids: [],
      }

      topic_index = { GOVUK_HOMEPAGE_CONTENT_ID => govuk_homepage_topic }
      unroll(topic_index, raw_level_one_topics, GOVUK_HOMEPAGE_CONTENT_ID)
      topic_index
    end
  end

  def raw_level_one_topics
    @raw_level_one_topics ||= begin
      start_time = Time.zone.now

      topics = publishing_api.get_expanded_links(GOVUK_HOMEPAGE_CONTENT_ID)
        .dig("expanded_links", "level_one_taxons")

      topics.each do |raw_topic|
        raise GdsApi::TimedOutException.new if Time.zone.now - start_time > TOPIC_INDEX_TIMEOUT

        topic_content_id = raw_topic["content_id"]
        raw_topic["links"] = publishing_api.get_expanded_links(topic_content_id)["expanded_links"]
      end

      topics.sort_by { |raw_topic| raw_topic["title"] }
    end
  end

  def unroll(topic_index, raw_topics, raw_parent_topic)
    raw_topics.each do |raw_topic|
      raw_child_topics = raw_topic.dig("links", "child_taxons").to_a
      raw_child_topics = raw_child_topics.sort_by { |raw_child_topic| raw_child_topic["title"] }

      topic = {
        content_id: raw_topic["content_id"],
        title: raw_topic["title"],
        child_content_ids: raw_child_topics.map { |raw_child_topic| raw_child_topic["content_id"] },
        parent_content_id: raw_parent_topic["content_id"],
        legacy_topic_content_ids: legacy_topic_content_ids(raw_topic),
      }

      topic_index[raw_topic["content_id"]] = topic
      unroll(topic_index, raw_child_topics, raw_topic)
    end
  end

  def legacy_topic_content_ids(raw_topic)
    legacy_taxons = raw_topic.dig("links", "legacy_taxons").to_a
    legacy_taxons = legacy_taxons.select { |legacy_taxon| legacy_taxon["document_type"] == "topic" }
    legacy_taxons.map { |legacy_taxon| legacy_taxon["content_id"] }
  end

  def publishing_api
    GdsApi.publishing_api_v2
  end
end
