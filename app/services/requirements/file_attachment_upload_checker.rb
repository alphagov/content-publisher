# frozen_string_literal: true

module Requirements
  class FileAttachmentUploadChecker
    TITLE_MAX_LENGTH = 255

    attr_reader :file, :title

    def initialize(file, title)
      @file = file
      @title = title
    end

    def issues
      issues = []

      unless file
        issues << Issue.new(:file_attachment_upload, :no_file)
        return CheckerIssues.new(issues)
      end

      if title.blank?
        issues << Issue.new(:file_attachment_title, :blank)
      end

      if title.to_s.size > TITLE_MAX_LENGTH
        issues << Issue.new(:file_attachment_title,
                            :too_long,
                            max_length: TITLE_MAX_LENGTH)
      end

      CheckerIssues.new(issues)
    end
  end
end
