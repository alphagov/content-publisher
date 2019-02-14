# frozen_string_literal: true

# Represents a particular revision of a document - acting as a snapshot to
# a particular user's edit.
#
# This model stores as little data as possible by having associations to more
# specific types of revision and delegating its methods to them.
#
# This model is immutable
class Revision < ApplicationRecord
  COMPARISON_IGNORE_FIELDS = %w[id number created_at created_by_id].freeze

  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :lead_image_revision, class_name: "Image::Revision", optional: true

  belongs_to :document

  belongs_to :content_revision

  belongs_to :metadata_revision

  belongs_to :tags_revision

  belongs_to :preceded_by,
             class_name: "Revision",
             optional: true

  has_and_belongs_to_many :statuses, -> { order("statuses.created_at DESC") }

  has_and_belongs_to_many :editions, -> { order("editions.number DESC") }

  has_and_belongs_to_many :image_revisions,
                          -> { order("image_revisions.image_id ASC") },
                          class_name: "Image::Revision",
                          association_foreign_key: "image_revision_id",
                          join_table: "revisions_image_revisions"

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
           :scheduled_publishing_datetime,
           to: :metadata_revision

  delegate :tags, to: :tags_revision

  def self.create_initial(document, user = nil, tags = {})
    Revision.create!(
      created_by: user,
      document: document,
      number: document.next_revision_number,
      content_revision: ContentRevision.new(created_by: user),
      metadata_revision: MetadataRevision.new(
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

  def build_revision_update_for_lead_image_upsert(image_revision, lead_image_revision, user)
    revisions = image_revisions.reject { |ir| ir.image_id == image_revision.image_id }

    attributes = {
      image_revisions: revisions + [image_revision],
      lead_image_revision: lead_image_revision,
    }

    build_revision_update(attributes, user)
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
    image_revisions_differ = image_revision_ids.to_set != other_revision.image_revision_ids.to_set

    attributes_differ || image_revisions_differ
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
      # we use dup to shallow clone the record which won't work unless data
      # is persisted (clone would be approriate) - it seems unlikely this
      # would need to be run with something unpersisted
      raise "Can't update from an unpersisted record" if preceding_revision.new_record?

      next_revision = preceding_revision.dup
      content_revision(next_revision)
      metadata_revision(next_revision)
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

    def metadata_revision(next_revision)
      metadata = attributes.slice(
        :update_type,
        :change_note,
        :scheduled_publishing_datetime,
      )

      unless metadata.empty?
        revision = next_revision.metadata_revision
                                .build_revision_update(metadata, user)
        next_revision.metadata_revision = revision
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
      return unless attributes.has_key?(:lead_image_revision)

      next_revision.lead_image_revision = attributes[:lead_image_revision]
    end

    def image_revisions(next_revision)
      if attributes.has_key?(:image_revisions)
        next_revision.image_revisions = attributes[:image_revisions]
      else
        next_revision.image_revision_ids = preceding_revision.image_revision_ids
      end
    end
  end
end
