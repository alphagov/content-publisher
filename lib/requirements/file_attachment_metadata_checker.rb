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

      issues
    end

  private

    def valid_isbn?(isbn)
      isbn.blank? || ISBN10_REGEX.match?(isbn) || ISBN13_REGEX.match?(isbn)
    end
  end
end
