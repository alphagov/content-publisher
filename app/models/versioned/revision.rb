# frozen_string_literal: true

module Versioned
  # A model that represents a particular revision of a document. An edition
  # always has a revision for the current state of it and then there are past
  # revisions that represent all the changes a document has been through.
  class Revision < ApplicationRecord
    self.table_name = "versioned_revisions"

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    belongs_to :lead_image_revision,
               class_name: "Versioned::ImageRevision",
               optional: true,
               foreign_key: :lead_image_revision_id
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

    has_and_belongs_to_many :image_revisions,
                            class_name: "Versioned::ImageRevision",
                            join_table: "versioned_revision_image_revisions"

    enum update_type: { major: "major", minor: "minor" }

    def readonly?
      !new_record?
    end

    def build_next_revision(attributes, user)
      dup.tap do |revision|
        revision.assign_attributes(attributes.merge(created_by: user))
        if !attributes.has_key?(:image_revision_ids) && !attributes.has_key?(:image_revisions)
          revision.image_revision_ids = image_revision_ids
        end
      end
    end

    def build_next_revision_for_image_upsert(image_revision, user)
      revisions = image_revisions.reject { |ir| ir.image_id == image_revision.image_id }
      attributes = { image_revisions: revisions + [image_revision] }

      if lead_image_revision&.image_id == image_revision.image_id
        attributes[:lead_image_revision] = image_revision
      end

      build_next_revision(attributes, user)
    end

    def build_next_revision_for_image_removed(image_revision, user)
      attributes = { image_revisions: image_revisions - [image_revision] }

      if lead_image_revision == image_revision
        attributes[:lead_image_revision] = nil
      end

      build_next_revision(attributes, user)
    end

    def title_or_fallback
      title.presence || I18n.t!("documents.untitled_document")
    end

    def image_revisions_without_lead
      image_revisions.reject { |i| i.id == lead_image_revision_id }
    end
  end
end
