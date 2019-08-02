# frozen_string_literal: true

module Versioning
  class RevisionUpdater < BaseUpdater
    include RevisionUpdater::Image
    include RevisionUpdater::FileAttachment

    def column_names
      sub_updaters.keys + %i[lead_image_revision]
    end

    def collection_names
      %i[image_revisions file_attachment_revisions]
    end

    def assign(fields)
      fields = fields.to_h.symbolize_keys

      sub_updaters.map do |column_name, updater|
        updater.assign(fields.slice(*updater.column_names))
        dup_revision.assign_attributes(column_name => updater.next_revision)
      end

      sub_columns = sub_updaters.values.flat_map(&:column_names)
      dup_revision.assign_attributes(fields.except(*sub_columns))
    end

    def changes
      changed_columns
        .merge(*sub_updaters.values.map(&:changes))
        .merge(changed_collections)
    end

  private

    def changed_collections
      old_key_vals = collection_names.map { |c| [c, revision.public_send(c).to_a] }
      new_key_vals = collection_names.map { |c| [c, dup_revision.public_send(c).to_a] }
      Hash[new_key_vals - old_key_vals]
    end

    def dup_revision
      @dup_revision ||= revision.dup.tap do |r|
        r.created_by = user
        r.number = revision.document.next_revision_number
        r.image_revisions = revision.image_revisions
        r.file_attachment_revisions = revision.file_attachment_revisions
        r.preceded_by = revision
      end
    end

    def sub_updaters
      @sub_updaters ||= {
        metadata_revision: SubRevisionUpdater.new(revision.metadata_revision, user),
        content_revision: SubRevisionUpdater.new(revision.content_revision, user),
        tags_revision: SubRevisionUpdater.new(revision.tags_revision, user),
      }
    end
  end
end
