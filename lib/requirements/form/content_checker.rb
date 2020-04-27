class Requirements::Form::ContentChecker < Requirements::Checker
  attr_reader :edition, :params

  def initialize(edition, params)
    @edition = edition
    @params = params
  end

  def check
    edition.document_type.contents.each do |field|
      issues.push(*field.form_issues(edition, params))
    end
  end
end
