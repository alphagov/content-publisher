# frozen_string_literal: true

module Versioning
  class FileAttachmentRevisionUpdater < BaseUpdater
    def column_names
      sub_updaters.keys + %i[blob_revision]
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
      changed_columns.merge(*sub_updaters.values.map(&:changes))
    end

  private

    def dup_revision
      @dup_revision ||= revision.dup.tap { |r| r.created_by = user }
    end

    def sub_updaters
      @sub_updaters ||= {
        metadata_revision: SubRevisionUpdater.new(revision.metadata_revision, user),
      }
    end
  end
end
