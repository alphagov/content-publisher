module Requirements
  class FileAttachmentMetadataChecker
    UNIQUE_REF_MAX_LENGTH = 255
    ISBN10_REGEX = /^(?:\d[\ -]?){9}[\dX]$/i.freeze
    ISBN13_REGEX = /^(?:\d[\ -]?){13}$/i.freeze

    attr_reader :isbn, :unique_reference

    def initialize(params)
      @isbn = params[:isbn]
      @unique_reference = params[:unique_reference]
    end

    def pre_update_issues
      isbn_issues + unique_reference_issues
    end

  private

    def isbn_issues
      issues = CheckerIssues.new

      unless isbn.blank? || ISBN10_REGEX.match?(isbn) || ISBN13_REGEX.match?(isbn)
        issues.create(:file_attachment_isbn, :invalid)
      end

      issues
    end

    def unique_reference_issues
      issues = CheckerIssues.new

      if unique_reference.present? &&
          unique_reference.to_s.size > UNIQUE_REF_MAX_LENGTH
        issues.create(:file_attachment_unique_reference,
                      :too_long,
                      max_length: UNIQUE_REF_MAX_LENGTH)
      end

      issues
    end
  end
end
