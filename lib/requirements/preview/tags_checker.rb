class Requirements::Preview::TagsChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def issues
    issues = Requirements::CheckerIssues.new

    edition.document_type.tags.each do |tag|
      issues += tag.pre_preview_issues(edition)
    end

    issues
  end
end
