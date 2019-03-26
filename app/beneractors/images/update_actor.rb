# frozen_string_literal: true

require "beneractors/beneractor"

module Images
  class UpdateActor < Beneractors::Beneractor
    def pre_op
      export :edition, Edition.find_current(document: document)
      edition.lock!

      export :image_revision, edition.image_revisions.find_by!(image_id: image_id)
      image_updater = Versioning::ImageRevisionUpdater.new(image_revision, user)

      image_updater.assign(update_params)
      export :next_image_revision, image_updater.next_revision

      export :issues, Requirements::ImageRevisionChecker.new(next_image_revision)
                                                 .pre_preview_metadata_issues

      abort!(:issues) if issues.any?

      export :updater, Versioning::RevisionUpdater.new(edition.revision, user)
      updater.update_image(next_image_revision, lead_image == "on")
      abort! unless updater.changed?
    end

    def op
      export :timeline_entry_type,
        if updater.selected_lead_image?
          :lead_image_selected
        elsif updater.removed_lead_image?
          :lead_image_removed
        else
          :image_updated
        end

      TimelineEntry.create_for_revision(
        entry_type: timeline_entry_type,
        edition: edition,
      )

      edition.assign_revision(updater.next_revision, user)
      edition.save!
      success!(timeline_entry_type)
    end

    def post_op
      PreviewService.new(edition).try_create_preview
    end
  end
end
