# frozen_string_literal: true

class Topic
  include ActiveModel::Model

  def self.govuk_homepage
    find(TopicIndexService::GOVUK_HOMEPAGE_CONTENT_ID)
  end

  def self.find(topic_content_id)
    TopicIndexService.new.index[topic_content_id]
  end

  attr_accessor :title, :child_content_ids, :legacy_topic_content_ids, :parent_content_id, :content_id

  def breadcrumb
    ancestors + [self]
  end

  def children
    child_content_ids.map(&Topic.method(:find))
  end

  def parent
    Topic.find(parent_content_id)
  end

  def ancestors
    parent ? parent.ancestors + [parent] : []
  end
end
