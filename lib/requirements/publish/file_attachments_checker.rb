class Requirements::Publish::FileAttachmentsChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def check
    return unless edition.document_type.attachments.featured?

    edition.file_attachment_revisions.each do |attachment|
      if attachment.official_document_type.blank?
        issues.create(:file_attachment_official_document_type,
                      :blank,
                      filename: attachment.filename,
                      attachment_revision: attachment)
      end
    end
  end
end
