# frozen_string_literal: true

module Versioning
  class SubRevisionUpdater
    attr_reader :revision, :user

    def initialize(revision, user)
      @revision = revision
      @user = user
    end

    def assign_attributes(attributes)
      attributes = attributes.to_h.symbolize_keys
      dup_revision.assign_attributes(attributes.slice(*attribute_keys))
      next_revision
    end

    def changed?
      changed_attributes.present?
    end

    def changed_attributes
      attributes = Hash[attribute_keys.map { |a| [a, revision.public_send(a)] }]
      dup_attributes = Hash[attribute_keys.map { |a| [a, dup_revision.public_send(a)] }]
      Hash[dup_attributes.to_a - attributes.to_a]
    end

    def next_revision
      changed? ? dup_revision : revision
    end

    def attribute_keys
      @attribute_keys ||= revision.class.column_names.map(&:to_sym) -
        %i[created_by id created_at created_by_id]
    end

  private

    def dup_revision
      @dup_revision ||= begin
        dup_revision = revision.dup
        dup_revision.created_by = user
        dup_revision
      end
    end
  end
end
