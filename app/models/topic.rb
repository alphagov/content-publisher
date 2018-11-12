# frozen_string_literal: true

class Topic
  def self.govuk_homepage
    find(TopicIndex::GOVUK_HOMEPAGE_CONTENT_ID)
  end

  def self.find(topic_content_id)
    TopicIndex.new.index[topic_content_id]
  end

  attr_reader :title, :child_content_ids, :legacy_topic_content_ids, :parent_content_id, :content_id

  def initialize(params)
    @content_id = params[:content_id]
    @title = params[:title]
    @child_content_ids = params[:child_content_ids]
    @legacy_topic_content_ids = params[:legacy_topic_content_ids]
    @parent_content_id = params[:parent_content_id]
  end

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
