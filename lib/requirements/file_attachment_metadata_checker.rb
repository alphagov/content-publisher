module Requirements
  class FileAttachmentMetadataChecker
    UNIQUE_REF_MAX_LENGTH = 255
    ISBN10_REGEX = /^(?:\d[\ -]?){9}[\dX]$/i.freeze
    ISBN13_REGEX = /^(?:\d[\ -]?){13}$/i.freeze

    def pre_update_issues(params)
      issues = CheckerIssues.new

      unless valid_isbn?(params[:isbn])
        issues.create(:file_attachment_isbn,
                      :invalid)
      end

      if params[:unique_reference].to_s.size > UNIQUE_REF_MAX_LENGTH
        issues.create(:file_attachment_unique_reference,
                      :too_long,
                      max_length: UNIQUE_REF_MAX_LENGTH)
      end

      if params[:official_document_type].blank?
        issues.create(:file_attachment_official_document_type,
                      :blank)
      end

      if blank_paper_number?("command", params)
        issues.create(:file_attachment_command_paper_number,
                      :blank)
      end

      if blank_paper_number?("act", params)
        issues.create(:file_attachment_act_paper_number,
                      :blank)
      end

      issues
    end

    def pre_publish_issues(attachment)
      issues = CheckerIssues.new

      if attachment.official_document_type.blank?
        issues.create(:file_attachment_official_document_type,
                      :blank,
                      filename: attachment.filename,
                      attachment_revision: attachment)
      end

      issues
    end

  private

    def valid_isbn?(isbn)
      isbn.blank? || ISBN10_REGEX.match?(isbn) || ISBN13_REGEX.match?(isbn)
    end

    def blank_paper_number?(type, params)
      params[:official_document_type] == "#{type}_paper" &&
        params[:"#{type}_paper_number"].blank?
    end
  end
end
