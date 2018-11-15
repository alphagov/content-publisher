# frozen_string_literal: true

class Topic
  include ActiveModel::Model

  def self.govuk_homepage(index)
    find(TopicIndexService::GOVUK_HOMEPAGE_CONTENT_ID, index)
  end

  def self.find(topic_content_id, index)
    raw_topic = index.lookup(topic_content_id)
    raw_topic ? new(raw_topic.merge(index: index)) : nil
  end

  attr_accessor :title, :child_content_ids, :legacy_topic_content_ids, :parent_content_id, :content_id, :index

  delegate :hash, to: :content_id

  def ==(other)
    content_id == other.content_id
  end

  def eql?(other)
    self == other
  end

  def breadcrumb
    ancestors + [self]
  end

  def children
    child_content_ids.map { |child_content_id| Topic.find(child_content_id, index) }
  end

  def parent
    Topic.find(parent_content_id, index)
  end

  def ancestors
    parent ? parent.ancestors + [parent] : []
  end
end
