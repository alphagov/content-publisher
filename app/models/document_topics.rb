# frozen_string_literal: true

class DocumentTopics
  include ActiveModel::Model

  attr_accessor :document, :version, :topics, :index

  def self.find_by_document(document, index)
    publishing_api = GdsApi.publishing_api_v2
    links = publishing_api.get_links(document.content_id)
    topic_content_ids = links.dig("links", "taxons").to_a

    new(
      index: index,
      document: document,
      version: links["version"],
      topics: topic_content_ids.map { |topic_content_id| Topic.find(topic_content_id, index) }.compact,
    )
  rescue GdsApi::HTTPNotFound
    new(
      index: index,
      document: document,
      version: nil,
      topics: [],
    )
  end

  def patch(topic_content_ids, version)
    topics = topic_content_ids.map { |topic_content_id| Topic.find(topic_content_id, index) }.compact
    self.version = version

    GdsApi.publishing_api_v2.patch_links(
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
end
