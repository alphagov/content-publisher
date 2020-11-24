class DocumentType::TextField
  attr_reader :name, :label

  def initialize(options)
    @name = options.fetch("name")
    @label = options.fetch("label")
  end

  def id
    "text"
  end

  def payload(edition)
    {
      details: { name.to_sym => edition.contents[name] }
    }
  end

  def updater_params(_edition, params)
    { contents: { name.to_sym => params[name]&.strip } }
  end

  def form_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end

  def preview_issues(_edition)
    Requirements::CheckerIssues.new
  end

  def publish_issues(_edition)
    Requirements::CheckerIssues.new
  end
end
