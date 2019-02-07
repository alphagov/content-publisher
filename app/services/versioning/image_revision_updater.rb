# frozen_string_literal: true

module Versioning
  class ImageRevisionUpdater < BaseUpdater
    def initialize(*args)
      super
      track_attributes(%i[metadata_revision file_revision])
    end

    def assign_attributes(attributes)
      super(attributes.merge(
        metadata_revision: metadata_updater.assign_attributes(attributes),
        file_revision: file_updater.assign_attributes(attributes),
      ))
    end

    def changed_attributes
      super.merge(metadata_updater.changed_attributes)
        .merge(file_updater.changed_attributes)
    end

  private

    def metadata_updater
      @metadata_updater ||= BaseUpdater.new(revision.metadata_revision, user)
        .track_attributes(%i[alt_text caption credit])
    end

    def file_updater
      @file_updater ||= BaseUpdater.new(revision.file_revision, user)
        .track_attributes(%i[crop_x crop_y crop_width crop_height])
    end
  end
end
