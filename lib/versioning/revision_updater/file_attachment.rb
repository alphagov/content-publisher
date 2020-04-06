module Versioning
  class RevisionUpdater
    module FileAttachment
      def add_file_attachment(attachment_revision)
        if attachment_exists?(attachment_revision)
          raise "Cannot add another revision for the same file attachment"
        end

        new_revisions = revision.file_attachment_revisions + [attachment_revision]
        assign(file_attachment_revisions: new_revisions)
        update_attachment_ordering
      end

      def update_file_attachment(attachment_revision)
        unless attachment_exists?(attachment_revision)
          raise "Cannot update a file attachment that doesn't exist"
        end

        other_revisions = other_file_attachments(attachment_revision)
        assign(file_attachment_revisions: other_revisions + [attachment_revision])
      end

      def remove_file_attachment(attachment_revision)
        assign(file_attachment_revisions: other_file_attachments(attachment_revision))
        update_attachment_ordering
      end

    private

      def attachment_exists?(attachment_revision)
        revision.file_attachment_revisions.find do |far|
          far.file_attachment_id == attachment_revision.file_attachment_id
        end
      end

      def other_file_attachments(attachment_revision)
        revision.file_attachment_revisions
          .reject { |ar| ar.file_attachment_id == attachment_revision.file_attachment_id }
      end

      def update_attachment_ordering
        return unless revision.document_type.attachments.featured?

        new_ordering = next_revision.featured_attachments.map(&:featured_attachment_id)
        assign(featured_attachment_ordering: new_ordering)
      end
    end
  end
end
