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
        child_topic_content_ids: level_one_topics.map { |level_one_topic| level_one_topic["content_id"] },
        legacy_topics: [],
      }

      unroll(index, level_one_topics, GOVUK_HOMEPAGE_CONTENT_ID)
      index
    end
  end

  def patch_topics(document, topic_content_ids, version)
    legacy_topic_content_ids = topic_content_ids.map { |topic_content_id|
      topic_breadcrumb(topic_content_id).map { |topic| topic[:legacy_topics] }
    }.flatten.uniq

    publishing_api.patch_links(
      document.content_id,
      links: { taxons: cleanup_superfluous_topics(topic_content_ids), topics: legacy_topic_content_ids },
      previous_version: version,
    )
  end

  def topics_for_document(document)
    links = publishing_api.get_links(document.content_id)
    topic_content_ids = links.dig("links", "taxons").to_a
    [topic_content_ids, links["version"]]
  end

  def topic_breadcrumb(topic_content_id)
    breadcrumb_content_ids = ancestor_content_ids(topic_content_id) + [topic_content_id]
    breadcrumb_content_ids.map { |breadcrumb_content_id| topic_index[breadcrumb_content_id] }
  end

private

  def unroll(index, topics, parent_topic)
    topics.each do |topic|
      child_topics = topic.dig("links", "child_taxons").to_a

      index[topic["content_id"]] = {
        title: topic["title"],
        child_topic_content_ids: child_topics.map { |child_topic| child_topic["content_id"] },
        parent_topic_content_id: parent_topic["content_id"],
        legacy_topics: legacy_topics(topic),
      }

      unroll(index, child_topics, topic)
    end
  end

  def cleanup_superfluous_topics(topic_content_ids)
    all_ancestor_content_ids = topic_content_ids.map { |topic_content_id|
      ancestor_content_ids(topic_content_id)
    }.flatten

    topic_content_ids - all_ancestor_content_ids
  end

  def ancestor_content_ids(topic_content_id)
    parent_content_id = topic_index[topic_content_id][:parent_topic_content_id]
    parent_content_id ? ancestor_content_ids(parent_content_id) + [parent_content_id] : []
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

  def legacy_topics(topic)
    topic.dig("links", "legacy_taxons").to_a
      .select { |legacy_taxon| legacy_taxon["document_type"] == "topic" }
      .map { |legacy_taxon| legacy_taxon["content_id"] }
  end

  def publishing_api
    GdsApi.publishing_api_v2
  end
end
