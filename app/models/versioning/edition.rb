# frozen_string_literal: true

module Versioning
  class Edition < ApplicationRecord
    self.table_name = "versioned_editions"

    before_create do
      # set a default value for last_edited_at works better than using DB default
      self.last_edited_at = Time.zone.now unless last_edited_at
    end

    after_save do
      # Add current revision to the wider revisions collection
      revisions << current_revision unless revisions.include?(current_revision)
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
               class_name: "Versioning::Document",
               inverse_of: :editions

    belongs_to :current_revision,
               class_name: "Versioning::Revision",
               inverse_of: :current_for_editions

    has_and_belongs_to_many :revisions,
                            class_name: "Versioning::Revision",
                            join_table: "versioned_edition_revisions"

    delegate_missing_to :current_revision

    def self.create_initial(document, user = nil)
      revision = Revision.create!(created_by: user, document: document)

      create!(created_by: user,
              current: true,
              current_revision: revision,
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
