class Requirements::Preview::TagsChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition, **)
    @edition = edition
  end

  def check
    edition.document_type.tags.each do |tag|
      issues.push(*tag.preview_issues(edition))
    end
  end
end
