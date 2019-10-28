# frozen_string_literal: true

class DocumentTopics
  include ActiveModel::Model

  attr_accessor :document, :version, :topic_content_ids, :index

  def self.find_by_document(document, index)
    publishing_api = GdsApi.publishing_api_v2
    links = publishing_api.get_links(document.content_id)

    new(
      index: index,
      document: document,
      version: links["version"],
      topic_content_ids: links.dig("links", "taxons").to_a,
    )
  rescue GdsApi::HTTPNotFound
    new(
      index: index,
      document: document,
      version: nil,
      topic_content_ids: [],
    )
  end

  def patch(updated_topic_content_ids, version)
    valid_user_topics = updated_topic_content_ids.map { |topic_content_id| Topic.find(topic_content_id, index) }.compact
    self.version = version

    GdsApi.publishing_api_v2.patch_links(
      document.content_id,
      links: {
        taxons: leaf_topic_content_ids(valid_user_topics) + unknown_taxon_content_ids,
        topics: legacy_topic_content_ids(valid_user_topics),
      },
      previous_version: version,
    )
  end

  def topics
    @topics ||= topic_content_ids.map { |topic_content_id| Topic.find(topic_content_id, index) }.compact
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

  def unknown_taxon_content_ids
    links = GdsApi.publishing_api_v2.get_links(document.content_id)
    previous_topic_content_ids = links.dig("links", "taxons").to_a

    previous_topic_content_ids.reject { |topic_content_id| index.lookup(topic_content_id) }
  rescue GdsApi::HTTPNotFound
    []
  end
end
