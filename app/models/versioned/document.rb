# frozen_string_literal: true

module Versioned
  # Represents all the versions of a piece of content in a particular locale
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
            class_name: "Versioned::Edition"

    has_one :live_edition,
            -> { where(live: true) },
            class_name: "Versioned::Edition"
    # rubocop:enable Rails/InverseOf

    has_many :editions,
             class_name: "Versioned::Edition",
             dependent: :restrict_with_exception

    has_many :revisions,
             class_name: "Versioned::Revision",
             dependent: :restrict_with_exception

    has_many :timeline_entries,
             class_name: "Versioned::TimelineEntry",
             dependent: :delete_all

    delegate :topics, to: :document_topics

    delegate :title, :base_path, :title_or_fallback, to: :current_edition, allow_nil: true, prefix: true
    delegate :title, :base_path, to: :live_edition, allow_nil: true, prefix: true

    scope :with_current_edition, -> do
      join_tables = { current_edition: %i[revision status] }
      joins(join_tables).includes(join_tables)
    end

    scope :using_base_path, ->(base_path) do
      left_outer_joins(current_edition: { revision: :content_revision },
                       live_edition: { revision: :content_revision })
        .where("versioned_content_revisions.base_path": base_path)
    end

    def self.find_by_param(content_id_and_locale)
      content_id, locale = content_id_and_locale.split(":")
      find_by!(content_id: content_id, locale: locale)
    end

    def self.create_initial(content_id: SecureRandom.uuid,
                            document_type_id:,
                            locale: "en",
                            user: nil,
                            tags: {})
      transaction do
        document = create!(content_id: content_id,
                           locale: locale,
                           document_type_id: document_type_id,
                           created_by: user)

        document.tap { |d| Edition.create_initial(d, user, tags) }
      end
    end

    def next_edition_number
      (editions.maximum(:number) || 0) + 1
    end

    def to_param
      content_id + ":" + locale
    end

    def document_type
      DocumentType.find(document_type_id)
    end

    def document_topics
      @document_topics_index ||= TopicIndexService.new
      DocumentTopics.find_by_document(self, @document_topics_index)
    end

    def newly_created?
      return false if !current_edition || current_edition.number == 1

      current_edition.created_at == current_edition.updated_at
    end

    def live?
      live_edition.present?
    end
  end
end
