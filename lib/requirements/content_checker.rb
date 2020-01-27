# frozen_string_literal: true

module Requirements
  class ContentChecker
    attr_reader :edition, :revision

    def initialize(edition, revision = nil)
      @edition = edition
      @revision = revision || edition.revision
    end

    def pre_preview_issues
      issues = CheckerIssues.new

      fields = [
        DocumentType::TitleAndBasePathField.new,
        DocumentType::SummaryField.new,
      ] + edition.document_type.contents

      fields.each do |field|
        issues += field.pre_preview_issues(edition, revision)
      end

      issues
    end

    def pre_publish_issues
      issues = CheckerIssues.new

      fields = [
        DocumentType::TitleAndBasePathField.new,
        DocumentType::SummaryField.new,
      ] + edition.document_type.contents

      fields.each do |field|
        issues += field.pre_publish_issues(edition, revision)
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
