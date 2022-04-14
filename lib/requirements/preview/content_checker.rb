class Requirements::Preview::ContentChecker
  include Requirements::Checker

  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def check
    edition.document_type.contents.each do |field|
      issues.push(*field.preview_issues(edition))
    end
  end
end
