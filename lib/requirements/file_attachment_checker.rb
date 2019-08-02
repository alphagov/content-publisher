# frozen_string_literal: true

module Requirements
  class FileAttachmentChecker
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
      "application/zip", # zip
      "text/xml", # xml, xsd
    ].freeze

    attr_reader :file, :title

    def initialize(file: nil, title: nil)
      @file = file
      @title = title
    end

    def pre_upload_issues
      title_issues + file_issues
    end

    def pre_update_issues
      issues = title_issues
      issues += file_issues if file.present?
      issues
    end

  private

    def unsupported_type?
      ALLOWED_FORMATS.exclude?(content_type)
    end

    def invalid_zip?
      return if content_type != "application/zip"

      Zip::File.open(file.path) do |zf|
        zf.any? do |entry|
          type = Marcel::MimeType.for(entry.get_input_stream, name: entry.name)

          # We don't allow nested archives
          ALLOWED_FORMATS.exclude?(type) || type == "application/zip"
        end
      end
    end

    def content_type
      @content_type ||= Marcel::MimeType.for(file,
                                             declared_type: file.content_type,
                                             name: file.original_filename)
    end

    def title_issues
      issues = CheckerIssues.new

      if title.blank?
        issues << Issue.new(:file_attachment_title, :blank)
      end

      if title.to_s.size > TITLE_MAX_LENGTH
        issues << Issue.new(:file_attachment_title,
                            :too_long,
                            max_length: TITLE_MAX_LENGTH)
      end

      issues
    end

    def file_issues
      issues = CheckerIssues.new

      unless file
        issues << Issue.new(:file_attachment_upload, :no_file)
        return issues
      end

      if invalid_zip?
        issues << Issue.new(:file_attachment_upload, :zip_unsupported_type)
        return issues
      end

      if unsupported_type?
        issues << Issue.new(:file_attachment_upload, :unsupported_type)
      end

      issues
    end
  end
end
