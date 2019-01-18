# frozen_string_literal: true

module Versioned
  module Requirements
    class ImageRevisionChecker
      ALT_TEXT_MAX_LENGTH = 125
      CAPTION_MAX_LENGTH = 160
      CREDIT_MAX_LENGTH = 160

      attr_reader :image_revision

      def initialize(image_revision)
        @image_revision = image_revision
      end

      def pre_preview_metadata_issues
        issues = []

        if image_revision.alt_text.blank?
          issues << ::Requirements::Issue.new(:alt_text, :blank, filename: image_revision.filename)
        end

        if image_revision.alt_text.to_s.length > ALT_TEXT_MAX_LENGTH
          issues << ::Requirements::Issue.new(:alt_text, :too_long, max_length: ALT_TEXT_MAX_LENGTH, filename: image_revision.filename)
        end

        if image_revision.caption.to_s.length > CAPTION_MAX_LENGTH
          issues << ::Requirements::Issue.new(:caption, :too_long, max_length: CAPTION_MAX_LENGTH, filename: image_revision.filename)
        end

        if image_revision.credit.to_s.length > CREDIT_MAX_LENGTH
          issues << ::Requirements::Issue.new(:credit, :too_long, max_length: CREDIT_MAX_LENGTH, filename: image_revision.filename)
        end

        ::Requirements::CheckerIssues.new(issues)
      end

      def pre_preview_issues
        pre_preview_metadata_issues
      end
    end
  end
end
