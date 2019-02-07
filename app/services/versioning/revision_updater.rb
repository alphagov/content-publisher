# frozen_string_literal: true

module Versioning
  class RevisionUpdater < BaseUpdater
    def initialize(*args)
      super

      track_attributes(%i[metadata_revision
                          content_revision
                          tags_revision
                          image_revisions
                          lead_image_revision])
    end

    def assign_attributes(attributes)
      super(attributes.merge(
        metadata_revision: metadata_updater.assign_attributes(attributes),
        content_revision: content_updater.assign_attributes(attributes),
        tags_revision: tags_updater.assign_attributes(attributes),
      ))
    end

    def changed_attributes
      super.merge(metadata_updater.changed_attributes)
        .merge(content_updater.changed_attributes)
        .merge(tags_updater.changed_attributes)
    end

  private

    def metadata_updater
      @metadata_updater ||= BaseUpdater.new(revision.metadata_revision, user)
        .track_attributes(%i[update_type change_note])
    end

    def content_updater
      @content_updater ||= BaseUpdater.new(revision.content_revision, user)
        .track_attributes(%i[title base_path summary contents])
    end

    def tags_updater
      @tags_updater ||= BaseUpdater.new(revision.tags_revision, user)
        .track_attributes(%i[tags])
    end

    def dup_revision
      @dup_revision ||= begin
        dup_revision = super
        dup_revision.number = dup_revision.document.next_revision_number
        dup_revision
      end
    end
  end
end
