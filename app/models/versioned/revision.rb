# frozen_string_literal: true

module Versioned
  # A model that represents a particular revision of a document. An edition
  # always has a revision for the current state of it and then there are past
  # revisions that represent all the changes a document has been through.
  #
  # This model aims to store as little data as possible (since there are many
  # in the database) and has associations that store specific types of data,
  # these are delegated to so methods can still be ran on a revision
  class Revision < ApplicationRecord
    self.table_name = "versioned_revisions"

    COMPARISON_IGNORE_FIELDS = %w[id number created_at created_by_id].freeze

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

    belongs_to :content_revision,
               class_name: "Versioned::ContentRevision",
               foreign_key: :content_revision_id,
               inverse_of: :revisions

    belongs_to :update_revision,
               class_name: "Versioned::UpdateRevision",
               foreign_key: :update_revision_id,
               inverse_of: :revisions

    belongs_to :tags_revision,
               class_name: "Versioned::TagsRevision",
               foreign_key: :tags_revision_id,
               inverse_of: :revisions

    belongs_to :preceded_by,
               class_name: "Versioned::Revision",
               foreign_key: :preceded_by_id,
               optional: true,
               inverse_of: :followed_by

    has_one :followed_by,
            class_name: "Versioned::Revision",
            foreign_key: :preceded_by_id,
            inverse_of: :preceded_by,
            dependent: :nullify

    has_many :current_for_editions,
             class_name: "Versioned::Edition",
             foreign_key: :revision_id,
             inverse_of: :revision,
             dependent: :restrict_with_exception

    has_and_belongs_to_many :statuses,
                            -> { order("versioned_statuses.created_at DESC") },
                            class_name: "Versioned::Status",
                            join_table: "versioned_revision_statuses"

    has_many :editions,
             -> { distinct.reorder("versioned_editions.number DESC") },
             through: :statuses,
             source: :edition

    has_and_belongs_to_many :image_revisions,
                            -> { order("versioned_image_revisions.image_id ASC") },
                            class_name: "Versioned::ImageRevision",
                            join_table: "versioned_revision_image_revisions"

    delegate :title,
             :base_path,
             :summary,
             :contents,
             :title_or_fallback,
             to: :content_revision

    delegate :update_type,
             :change_note,
             :major?,
             :minor?,
             to: :update_revision

    delegate :tags, to: :tags_revision

    def self.create_initial(document, user = nil, tags = {})
      Revision.create!(
        created_by: user,
        document: document,
        number: document.next_revision_number,
        content_revision: ContentRevision.new(created_by: user),
        update_revision: UpdateRevision.new(
          change_note: "First published.",
          update_type: "major",
          created_by: user,
        ),
        tags_revision: TagsRevision.new(tags: tags, created_by: user),
      )
    end

    def readonly?
      !new_record?
    end

    def build_revision_update(attributes, user)
      BuildRevisionUpdate.new(attributes, user, self).build
    end

    def build_revision_update_for_image_upsert(image_revision, user)
      revisions = image_revisions.reject { |ir| ir.image_id == image_revision.image_id }
      attributes = { image_revisions: revisions + [image_revision] }

      if lead_image_revision&.image_id == image_revision.image_id
        attributes[:lead_image_revision] = image_revision
      end

      build_revision_update(attributes, user)
    end

    def build_revision_update_for_image_removed(image_revision, user)
      attributes = { image_revisions: image_revisions - [image_revision] }

      if lead_image_revision == image_revision
        attributes[:lead_image_revision] = nil
      end

      build_revision_update(attributes, user)
    end

    def different_to?(other_revision)
      raise "Must compare with a persisted record" if other_revision.new_record?

      other_attributes = other_revision.attributes.except(*COMPARISON_IGNORE_FIELDS)
      attributes_differ = attributes.except(*COMPARISON_IGNORE_FIELDS) != other_attributes

      # We need to check many-to-many relationship separately as it's not
      # included in attributes
      attributes_differ || different_image_revision_ids(other_revision.image_revision_ids)
    end

    def image_revisions_without_lead
      image_revisions.reject { |i| i.id == lead_image_revision_id }
    end

  private

    def different_image_revision_ids(other_image_revision_ids)
      return true if image_revision_ids.include?(nil)

      image_revision_ids.sort != other_image_revision_ids.sort
    end

    class BuildRevisionUpdate
      attr_reader :attributes, :user, :preceding_revision

      def initialize(attributes, user, preceding_revision)
        @attributes = HashWithIndifferentAccess.new(attributes)
        @user = user
        @preceding_revision = preceding_revision
      end

      def build
        # we use dup to shallow clone the record which won't work unless data
        # is persisted (clone would be approriate) - it seems unlikely this
        # would need to be run with something unpersisted
        raise "Can't update from an unpersisted record" if preceding_revision.new_record?

        next_revision = preceding_revision.dup
        content_revision(next_revision)
        update_revision(next_revision)
        tags_revision(next_revision)
        lead_image_revision(next_revision)
        image_revisions(next_revision)

        if next_revision.different_to?(preceding_revision)
          next_revision.tap do |r|
            r.number = r.document.next_revision_number
            r.created_by = user
            r.preceded_by = preceding_revision
          end
        else
          preceding_revision
        end
      end

    private

      def content_revision(next_revision)
        contents = attributes.slice(:title, :base_path, :summary, :contents)
        unless contents.empty?
          revision = preceding_revision.content_revision
                                       .build_revision_update(contents, user)
          next_revision.content_revision = revision
        end
      end

      def update_revision(next_revision)
        update = attributes.slice(:update_type, :change_note)
        unless update.empty?
          revision = next_revision.update_revision
                                  .build_revision_update(update, user)
          next_revision.update_revision = revision
        end
      end

      def tags_revision(next_revision)
        tags = attributes.slice(:tags)
        unless tags.empty?
          revision = next_revision.tags_revision
                                  .build_revision_update(tags, user)
          next_revision.tags_revision = revision
        end
      end

      def lead_image_revision(next_revision)
        if attributes.has_key?(:lead_image_revision)
          next_revision.lead_image_revision = attributes[:lead_image_revision]
        elsif attributes.has_key?(:lead_image_revision_id)
          next_revision.lead_image_revision_id = attributes[:lead_image_revision_id]
        end
      end

      def image_revisions(next_revision)
        if attributes.has_key?(:image_revisions)
          next_revision.image_revisions = attributes[:image_revisions]
        elsif attributes.has_key?(:image_revision_ids)
          next_revision.image_revision_ids = attributes[:image_revision_ids]
        else
          next_revision.image_revision_ids = preceding_revision.image_revision_ids
        end
      end
    end
  end
end
