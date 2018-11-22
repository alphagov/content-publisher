# frozen_string_literal: true

module Requirements
  class ImageChecker
    ALT_TEXT_MAX_LENGTH = 125
    CAPTION_MAX_LENGTH = 160

    attr_reader :image

    def initialize(image)
      @image = image
    end

    def pre_preview_metadata_issues
      issues = []

      if image.alt_text.blank?
        issues << Issue.new(:alt_text, :blank, filename: image.filename)
      end

      if image.alt_text.to_s.length > ALT_TEXT_MAX_LENGTH
        issues << Issue.new(:alt_text, :too_long, max_length: ALT_TEXT_MAX_LENGTH, filename: image.filename)
      end

      if @image.caption.to_s.length > CAPTION_MAX_LENGTH
        issues << Issue.new(:caption, :too_long, max_length: CAPTION_MAX_LENGTH, filename: image.filename)
      end

      CheckerIssues.new(issues)
    end

    def pre_preview_issues
      pre_preview_metadata_issues
    end
  end
end
