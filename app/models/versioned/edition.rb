# frozen_string_literal: true

module Versioned
  class Edition < ApplicationRecord
    self.table_name = "versioned_editions"

    before_create do
      # set a default value for last_edited_at works better than using DB default
      self.last_edited_at = Time.zone.now unless last_edited_at
    end

    after_save do
      # Add revision to the wider revisions collection
      revisions << revision unless revisions.include?(revision)
      # Store the edition on the status to keep a history
      status.update(edition: self) if status && !status.edition_id
    end

    attr_readonly :number, :document_id

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    belongs_to :last_edited_by,
               class_name: "User",
               optional: true,
               foreign_key: :last_edited_by_id
    # rubocop:enable Rails/InverseOf

    belongs_to :document,
               class_name: "Versioned::Document",
               inverse_of: :editions

    belongs_to :revision,
               class_name: "Versioned::Revision",
               inverse_of: :current_for_editions

    belongs_to :status,
               class_name: "Versioned::EditionStatus",
               inverse_of: :status_of

    has_many :statuses,
             class_name: "Versioned::EditionStatus",
             dependent: :restrict_with_exception,
             inverse_of: :edition

    has_and_belongs_to_many :revisions,
                            class_name: "Versioned::Revision",
                            join_table: "versioned_edition_revisions"

    delegate :user_facing_state, :publishing_api_sync, to: :status
    alias state user_facing_state

    delegate :content_id, :locale, :document_type, :topics, to: :document

    delegate_missing_to :revision

    def self.create_initial(document, user = nil, tags = {})
      revision = Revision.create!(created_by: user,
                                  document: document,
                                  tags: tags)
      status = EditionStatus.create!(created_by: user,
                                     user_facing_state: :draft,
                                     publishing_api_sync: :complete,
                                     revision_at_creation: revision)

      create!(created_by: user,
              current: true,
              revision: revision,
              status: status,
              document: document,
              number: document.next_edition_number,
              last_edited_by: user)
    end

    def update_last_edited_at(user, time = Time.zone.now)
      return if last_edited_at > time

      update!(last_edited_by: user, last_edited_at: time)
      document.update_last_edited_at(user, time)
    end
  end
end
