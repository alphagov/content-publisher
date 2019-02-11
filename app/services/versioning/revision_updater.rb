# frozen_string_literal: true

module Versioning
  class RevisionUpdater
    attr_reader :revision, :user

    def initialize(revision, user)
      @revision = revision
      @user = user
    end

    def assign_attributes(attributes)
      attributes = attributes.to_h.symbolize_keys.merge(
        metadata_revision: metadata_updater.assign_attributes(attributes),
        content_revision: content_updater.assign_attributes(attributes),
        tags_revision: tags_updater.assign_attributes(attributes),
      )

      dup_revision.assign_attributes(attributes.slice(*attribute_keys))
      next_revision
    end

    def changed?
      changed_attributes.present?
    end

    def changed_attributes
      attributes = Hash[attribute_keys.map { |a| [a, revision.public_send(a)] }]
      dup_attributes = Hash[attribute_keys.map { |a| [a, dup_revision.public_send(a)] }]
      changed_attributes = Hash[dup_attributes.to_a - attributes.to_a]

      changed_attributes.merge(metadata_updater.changed_attributes)
        .merge(content_updater.changed_attributes)
        .merge(tags_updater.changed_attributes)
    end

    def next_revision
      changed? ? dup_revision : revision
    end

  private

    def attribute_keys
      @attribute_keys ||= revision.class.reflect_on_all_associations.map(&:name) +
        revision.class.column_names.map(&:to_sym) -
        %i[created_by number preceded_by id created_at created_by_id preceded_by_id]
    end

    def metadata_updater
      @metadata_updater ||= SubRevisionUpdater.new(revision.metadata_revision, user)
    end

    def content_updater
      @content_updater ||= SubRevisionUpdater.new(revision.content_revision, user)
    end

    def tags_updater
      @tags_updater ||= SubRevisionUpdater.new(revision.tags_revision, user)
    end

    def dup_revision
      @dup_revision ||= begin
        dup_revision = revision.dup
        dup_revision.created_by = user
        dup_revision.number = dup_revision.document.next_revision_number
        dup_revision.image_revisions = revision.image_revisions
        dup_revision.preceded_by = revision
        dup_revision
      end
    end
  end
end
