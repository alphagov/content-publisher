class DocumentType::GovspeakField
  attr_reader :name, :label

  def initialize(options)
    @name = options.fetch("name")
    @label = options.fetch("label")
  end

  def id
    "govspeak"
  end

  def payload(edition)
    {
      details: {
        name.to_sym => GovspeakDocument.new(edition.contents[id], edition).payload_html,
      },
    }
  end

  def updater_params(_edition, params)
    { contents: { body: params[name]&.strip } }
  end

  def collection_params(params)
    { name.to_sym => params[name]&.strip }
  end

  def form_issues(edition, params)
    issues = Requirements::CheckerIssues.new

    unless GovspeakDocument.new(params[:contents][name], edition).valid?
      issues.create(name, :invalid_govspeak)
    end

    issues
  end

  def preview_issues(_edition)
    Requirements::CheckerIssues.new
  end

  def publish_issues(edition)
    issues = Requirements::CheckerIssues.new
    issues.create(name, :blank) if edition.contents[name].blank?
    issues
  end
end
