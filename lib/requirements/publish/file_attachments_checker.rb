class Requirements::Publish::FileAttachmentsChecker
  include Requirements::Checker

  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def check
    return unless edition.document_type.attachments.featured?

    edition.file_attachment_revisions.each do |attachment|
      next if attachment.official_document_type.present?

      issues.create(:file_attachment_official_document_type,
                    :blank,
                    filename: attachment.filename,
                    attachment_revision: attachment)
    end
  end
end
