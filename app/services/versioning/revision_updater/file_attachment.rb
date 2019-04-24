# frozen_string_literal: true

module Versioning
  class RevisionUpdater
    module FileAttachment
      def update_file_attachment(attachment_revision)
        revisions = other_file_attachments(attachment_revision) + [attachment_revision]
        assign(file_attachment_revisions: revisions)
      end

    private

      def other_file_attachments(attachment_revision)
        revision.file_attachment_revisions.reject do |far|
          far.file_attachment_id == attachment_revision.file_attachment_id
        end
      end
    end
  end
end
