# frozen_string_literal: true

module Versioning
  class RevisionUpdater
    module Image
      def add_image(image_revision)
        if image_exists?(image_revision)
          raise "Cannot add another revision for the same image"
        end

        assign(image_revisions: revision.image_revisions + [image_revision])
      end

      def update_image(image_revision, selected = false)
        unless image_exists?(image_revision)
          raise "Cannot update an image that doesn't exist"
        end

        assign(
          image_revisions: other_images(image_revision) + [image_revision],
          lead_image_revision: next_lead_image(image_revision, selected),
        )
      end

      def remove_image(image_revision)
        assign(
          image_revisions: other_images(image_revision),
          lead_image_revision: next_lead_image(image_revision),
        )
      end

      def selected_lead_image?
        changes[:lead_image_revision].present? &&
          revision.lead_image_revision&.image_id != changes[:lead_image_revision].image_id
      end

      def removed_lead_image?
        changed?(:lead_image_revision) && changes[:lead_image_revision].nil?
      end

    private

      def other_images(image_revision)
        revision.image_revisions.reject { |ir| ir.image_id == image_revision.image_id }
      end

      def image_exists?(image_revision)
        revision.image_revisions.find { |ir| ir.image_id == image_revision.image_id }
      end

      def next_lead_image(image_revision, selected = false)
        currently_lead = revision.lead_image_revision&.image_id == image_revision.image_id
        return image_revision if selected
        return if currently_lead

        revision.lead_image_revision
      end
    end
  end
end
