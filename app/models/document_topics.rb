# frozen_string_literal: true

class DocumentTopics
  include Enumerable

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def each
    topics, _version = with_version
    topics.each { |topic| yield topic }
  end

  def with_version
    @with_version ||= begin
      links = publishing_api.get_links(document.content_id)
      topic_content_ids = links.dig("links", "taxons").to_a

      topics = topic_content_ids.map(&Topic.method(:find))
      [topics, links["version"]]
    end
  end

  def patch(topic_content_ids, version)
    topics = topic_content_ids.map(&Topic.method(:find))

    publishing_api.patch_links(
      document.content_id,
      links: {
        taxons: leaf_topic_content_ids(topics),
        topics: legacy_topic_content_ids(topics),
      },
      previous_version: version,
    )
  end

private

  def leaf_topic_content_ids(topics)
    superfluous_topics = topics.map(&:ancestors).flatten
    (topics - superfluous_topics).map(&:content_id)
  end

  def legacy_topic_content_ids(topics)
    breadcrumbs = topics.map(&:breadcrumb).flatten
    breadcrumbs.map(&:legacy_topic_content_ids).flatten.uniq
  end

  def publishing_api
    GdsApi.publishing_api_v2
  end
end
