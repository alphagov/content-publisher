class Requirements::Preview::ContentChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def check
    edition.document_type.contents.each do |field|
      self.issues += field.preview_issues(edition)
    end
  end
end
