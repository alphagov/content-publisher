# frozen_string_literal: true

module Versioning
  class BaseUpdater
    attr_reader :revision, :user

    def initialize(revision, user)
      @revision = revision
      @user = user
    end

    def column_names
      raise "Not implemented"
    end

    def changed?(field = nil)
      field ? changes.key?(field) : changes.any?
    end

    def next_revision
      changed? ? dup_revision : revision
    end

    def changes
      raise "Not implemented"
    end

  protected

    def changed_columns
      old_key_vals = column_names.map { |c| [c, revision.public_send(c)] }
      new_key_vals = column_names.map { |c| [c, dup_revision.public_send(c)] }
      Hash[new_key_vals - old_key_vals]
    end

    def dup_revision
      raise "Not implemented"
    end
  end
end
