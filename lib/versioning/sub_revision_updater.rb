# frozen_string_literal: true

module Versioning
  class SubRevisionUpdater < BaseUpdater
    def column_names
      revision.class.column_names.map(&:to_sym) -
        %i[id created_by created_at created_by_id]
    end

    def assign(fields)
      dup_revision.assign_attributes(fields)
    end

    def changes
      changed_columns
    end

  private

    def dup_revision
      @dup_revision ||= revision.dup.tap { |r| r.created_by = user }
    end
  end
end
