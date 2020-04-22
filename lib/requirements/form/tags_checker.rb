class Requirements::Form::TagsChecker < Requirements::Checker
  attr_reader :edition, :params

  def initialize(edition, params)
    @edition = edition
    @params = params
  end

  def check
    edition.document_type.tags.each do |tag|
      self.issues += tag.form_issues(edition, params)
    end
  end
end
