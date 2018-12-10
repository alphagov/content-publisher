# frozen_string_literal: true

module Versioning
  class Document < ApplicationRecord
    self.table_name = "versioned_documents"

    attr_readonly :content_id, :locale, :document_type_id

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    has_one :current_edition,
            -> { where(current: true) },
            class_name: "Versioning::Edition"

    has_one :live_edition,
            -> { where(live: true) },
            class_name: "Versioning::Edition"
    # rubocop:enable Rails/InverseOf

    has_many :editions,
             class_name: "Versioning::Edition",
             dependent: :restrict_with_exception

    delegate :topics, to: :document_topics

    def self.find_by_param(content_id_and_locale)
      content_id, locale = content_id_and_locale.split(":")
      Document.find_by!(content_id: content_id, locale: locale)
    end

    def document_type
      DocumentType.find(document_type_id)
    end

    def document_topics
      @document_topics_index ||= TopicIndexService.new
      DocumentTopics.find_by_document(self, @document_topics_index)
    end
  end
end
