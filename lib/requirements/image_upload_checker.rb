# frozen_string_literal: true

require "mini_magick"

module Requirements
  class ImageUploadChecker
    include ActionView::Helpers::NumberHelper

    SUPPORTED_FORMATS = %w(image/jpeg image/png image/gif).freeze
    MAX_FILE_SIZE = 20.megabytes

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def issues
      issues = CheckerIssues.new

      unless file
        issues << Issue.new(:image_upload, :no_file)
        return CheckerIssues.new(issues)
      end

      if unsupported_type?
        issues << Issue.new(:image_upload, :unsupported_type)
        return CheckerIssues.new(issues)
      end

      if file.size >= MAX_FILE_SIZE
        issues << Issue.new(:image_upload, :too_big, max_size: number_to_human_size(MAX_FILE_SIZE))
      end

      issues
    end

  private

    def unsupported_type?
      SUPPORTED_FORMATS.exclude?(Marcel::MimeType.for(file))
    end
  end
end
