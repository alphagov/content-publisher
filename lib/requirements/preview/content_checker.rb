class Requirements::Preview::ContentChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def issues
    issues = Requirements::CheckerIssues.new

    edition.document_type.contents.each do |field|
      issues += field.pre_preview_issues(edition)
    end

    issues
  end
end
