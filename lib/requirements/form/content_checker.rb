class Requirements::Form::ContentChecker < Requirements::Checker
  attr_reader :edition, :params

  def initialize(edition, params)
    @edition = edition
    @params = params
  end

  def issues
    issues = Requirements::CheckerIssues.new

    edition.document_type.contents.each do |field|
      issues += field.pre_update_issues(edition, params)
    end

    issues
  end
end
