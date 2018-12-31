# frozen_string_literal: true

module Versioned
  class Revision < ApplicationRecord
    self.table_name = "versioned_revisions"

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    belongs_to :lead_image,
               class_name: "Versioned::Image",
               optional: true,
               foreign_key: :lead_image_id
    # rubocop:enable Rails/InverseOf

    belongs_to :document,
               class_name: "Versioned::Document",
               foreign_key: :document_id,
               inverse_of: :revisions

    has_many :current_for_editions,
             class_name: "Versioned::Edition",
             foreign_key: :revision_id,
             inverse_of: :revision,
             dependent: :restrict_with_exception

    has_and_belongs_to_many :editions,
                            class_name: "Versioned::Edition",
                            join_table: "versioned_edition_revisions"

    has_and_belongs_to_many :images,
                            class_name: "Versioned::Image",
                            join_table: "versioned_revision_images"

    def readonly?
      !new_record?
    end

    def build_next_revision(attributes, user)
      dup.tap do |revision|
        revision.assign_attributes(attributes.merge(created_by: user))
        revision.image_ids = image_ids
      end
    end

    def title_or_fallback
      title.presence || I18n.t!("documents.untitled_document")
    end
  end
end
