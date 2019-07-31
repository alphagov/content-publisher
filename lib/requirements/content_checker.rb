# frozen_string_literal: true

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
      issues = CheckerIssues.new

      if revision.title.blank?
        issues << Issue.new(:title, :blank)
      end

      if revision.title.to_s.size > TITLE_MAX_LENGTH
        issues << Issue.new(:title, :too_long, max_length: TITLE_MAX_LENGTH)
      end

      if revision.title.to_s.lines.count > 1
        issues << Issue.new(:title, :multiline)
      end

      if revision.summary.to_s.size > SUMMARY_MAX_LENGTH
        issues << Issue.new(:summary, :too_long, max_length: SUMMARY_MAX_LENGTH)
      end

      if revision.summary.to_s.lines.count > 1
        issues << Issue.new(:summary, :multiline)
      end

      edition.document_type.contents.each do |field|
        next unless field.type == "govspeak"

        unless GovspeakDocument.new(revision.contents[field.id], edition).valid?
          issues << Issue.new(field.id, :invalid_govspeak)
        end
      end

      issues
    end

    def pre_publish_issues
      issues = CheckerIssues.new

      if revision.summary.blank?
        issues << Issue.new(:summary, :blank)
      end

      edition.document_type.contents.each do |field|
        if revision.contents[field.id].blank?
          issues << Issue.new(field.id, :blank)
        end
      end

      if edition.document.live_edition &&
          revision.update_type == "major" &&
          revision.change_note.blank?
        issues << Issue.new(:change_note, :blank)
      end

      issues
    end
  end
end
