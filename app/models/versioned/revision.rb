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
      content_revision != other_revision.content_revision ||
        update_revision != other_revision.update_revision ||
        tags_revision != other_revision.tags_revision ||
        lead_image_revision != other_revision.lead_image_revision ||
        image_revisions != other_revision.image_revisions
    end

    def image_revisions_without_lead
      image_revisions.reject { |i| i.id == lead_image_revision_id }
    end

    class BuildRevisionUpdate
      attr_reader :attributes, :user, :preceding_revision

      def initialize(attributes, user, preceding_revision)
        @attributes = HashWithIndifferentAccess.new(attributes)
        @user = user
        @preceding_revision = preceding_revision
      end

      def build
        next_revision = preceding_revision.dup
        content_revision(next_revision)
        update_revision(next_revision)
        tags_revision(next_revision)
        lead_image_revision(next_revision)
        image_revisions(next_revision)

        if next_revision.different_to?(preceding_revision)
          next_revision.tap { |r| r.created_at = user }
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
