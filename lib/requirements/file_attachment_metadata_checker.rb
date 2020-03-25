module Requirements
  class FileAttachmentMetadataChecker
    UNIQUE_REF_MAX_LENGTH = 255

    attr_reader :unique_reference

    def initialize(unique_reference: nil)
      @unique_reference = unique_reference
    end

    def pre_update_issues
      unique_reference_issues
    end

  private

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
