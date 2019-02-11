# frozen_string_literal: true

module Versioning
  class ImageRevisionUpdater
    attr_reader :revision, :user, :attribute_keys

    def initialize(revision, user)
      @revision = revision
      @user = user
      @attribute_keys = %i[metadata_revision file_revision]
    end

    def assign_attributes(attributes)
      attributes = attributes.to_h.symbolize_keys.merge(
        metadata_revision: metadata_updater.assign_attributes(attributes),
        file_revision: file_updater.assign_attributes(attributes),
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
        .merge(file_updater.changed_attributes)
    end

    def next_revision
      changed? ? dup_revision : revision
    end

  private

    def metadata_updater
      @metadata_updater ||= SubRevisionUpdater.new(revision.metadata_revision, user)
        .track_attributes(%i[alt_text caption credit])
    end

    def file_updater
      @file_updater ||= SubRevisionUpdater.new(revision.file_revision, user)
        .track_attributes(%i[crop_x crop_y crop_width crop_height])
    end

    def dup_revision
      @dup_revision ||= begin
        dup_revision = revision.dup
        dup_revision.created_by = user
        dup_revision
      end
  end
end
