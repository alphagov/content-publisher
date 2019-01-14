# frozen_string_literal: true

module Versioned
  module Requirements
    class ContentChecker
      TITLE_MAX_LENGTH = 300
      SUMMARY_MAX_LENGTH = 600

      attr_reader :edition, :revision

      def initialize(edition, revision = nil)
        @edition = edition
        @revision = revision || edition.revision
      end

      def pre_preview_issues
        issues = []

        if revision.title.blank?
          issues << ::Requirements::Issue.new(:title, :blank)
        end

        if revision.title.to_s.size > TITLE_MAX_LENGTH
          issues << ::Requirements::Issue.new(:title, :too_long, max_length: TITLE_MAX_LENGTH)
        end

        if revision.title.to_s.lines.count > 1
          issues << ::Requirements::Issue.new(:title, :multiline)
        end

        if revision.summary.to_s.size > SUMMARY_MAX_LENGTH
          issues << ::Requirements::Issue.new(:summary, :too_long, max_length: SUMMARY_MAX_LENGTH)
        end

        if revision.summary.to_s.lines.count > 1
          issues << ::Requirements::Issue.new(:summary, :multiline)
        end

        ::Requirements::CheckerIssues.new(issues)
      end

      def pre_publish_issues
        issues = []

        if revision.summary.blank?
          issues << ::Requirements::Issue.new(:summary, :blank)
        end

        edition.document_type.contents.each do |field|
          if revision.contents[field.id].blank?
            issues << ::Requirements::Issue.new(field.id, :blank)
          end
        end

        if edition.document.live? && revision.update_type == "major" && revision.change_note.blank?
          issues << ::Requirements::Issue.new(:change_note, :blank)
        end

        ::Requirements::CheckerIssues.new(issues)
      end
    end
  end
end
