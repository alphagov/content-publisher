# frozen_string_literal: true

module Requirements
  class FileAttachmentUploadChecker
    TITLE_MAX_LENGTH = 255

    ALLOWED_FORMATS = [
      "text/csv", # csv
      "application/msword", # doc
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document", # docx
      "image/vnd.dxf", # dxf
      "image/gif", # gif
      "image/jpeg", # jpg
      "application/vnd.oasis.opendocument.presentation", # odp
      "application/vnd.oasis.opendocument.spreadsheet", # ods
      "application/vnd.oasis.opendocument.text", # odt
      "application/pdf", # pdf
      "image/png", # png
      "application/vnd.ms-powerpoint", # ppt
      "application/vnd.openxmlformats-officedocument.presentationml.presentation", # pptx
      "application/postscript", # ps, eps
      "application/rtf", # rtf
      "text/plain", # txt
      "application/vnd.ms-excel", # xls, xlt
      "application/vnd.ms-excel.sheet.macroenabled.12", # xlsm
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", # xlsx
      "application/xml", # xml
      "text/xml", # xml, xsd
    ].freeze

    attr_reader :file, :title

    def initialize(file, title)
      @file = file
      @title = title
    end

    def issues
      issues = []

      if title.blank?
        issues << Issue.new(:file_attachment_title, :blank)
      end

      if title.to_s.size > TITLE_MAX_LENGTH
        issues << Issue.new(:file_attachment_title,
                            :too_long,
                            max_length: TITLE_MAX_LENGTH)
      end

      unless file
        issues << Issue.new(:file_attachment_upload, :no_file)
        return CheckerIssues.new(issues)
      end

      if unsupported_type?
        issues << Issue.new(:file_attachment_upload, :unsupported_type)
      end

      CheckerIssues.new(issues)
    end

  private

    def unsupported_type?
      ALLOWED_FORMATS.exclude?(content_type)
    end

    def content_type
      Marcel::MimeType.for(file, declared_type: file.content_type, name: file.original_filename)
    end
  end
end
