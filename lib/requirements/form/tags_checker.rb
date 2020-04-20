class Requirements::Form::TagsChecker < Requirements::Checker
  attr_reader :edition, :params

  def initialize(edition, params)
    @edition = edition
    @params = params
  end

  def issues
    issues = Requirements::CheckerIssues.new

    edition.document_type.tags.each do |tag|
      issues += tag.pre_update_issues(edition, params)
    end

    issues
  end
end
