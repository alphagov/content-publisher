# frozen_string_literal: true

module Versioned
  class Document < ApplicationRecord
    self.table_name = "versioned_documents"

    before_create do
      # set a default value for last_edited_at works better than using DB default
      self.last_edited_at = Time.zone.now unless last_edited_at
    end

    attr_readonly :content_id, :locale, :document_type_id

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    belongs_to :last_edited_by,
               class_name: "User",
               optional: true,
               foreign_key: :last_edited_by_id

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

    delegate :topics, to: :document_topics

    delegate :title, :base_path, to: :current_edition, allow_nil: true, prefix: true
    delegate :title, :base_path, to: :live_edition, allow_nil: true, prefix: true

    scope :with_current_edition, -> do
      join_tables = { current_edition: %i[revision status] }
      joins(join_tables).includes(join_tables)
    end

    scope :using_base_path, ->(base_path) do
      left_outer_joins(current_edition: :revision,
                       live_edition: :revision)
        .where("versioned_revisions.base_path": base_path)
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
                           created_by: user,
                           last_edited_at: Time.zone.now,
                           last_edited_by: user)

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

    def update_last_edited_at(user, time = Time.zone.now)
      return if last_edited_at > time

      update!(last_edited_by: user, last_edited_at: time)
    end

    def newly_created?
      created_at == updated_at
    end

    def live?
      live_edition.present?
    end
  end
end
