# frozen_string_literal: true

module Versioning
  class RevisionUpdater
    module FileAttachment
      def add_file_attachment(attachment_revision)
        if attachment_exists?(attachment_revision)
          raise "Cannot add another revision for the same file attachment"
        end

        revisions = revision.file_attachment_revisions + [attachment_revision]
        assign(file_attachment_revisions: revisions)
      end

      def update_file_attachment(attachment_revision)
        unless attachment_exists?(attachment_revision)
          raise "Cannot update a file attachment that doesn't exist"
        end

        revisions = other_file_attachments(attachment_revision) + [attachment_revision]
        assign(file_attachment_revisions: revisions)
      end

      def remove_file_attachment(attachment_revision)
        assign(file_attachment_revisions: other_file_attachments(attachment_revision))
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
    end
  end
end
