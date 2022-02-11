class DocumentType::ChooseOneField
  attr_reader :name, :label, :input, :default, :options

  def initialize(options)
    @name = options.fetch("name")
    @label = options.fetch("label")
    @input = options.fetch("input", "radio")
    @default = options["default"]
    @options = options.fetch("options")
  end

  def id
    "choose_one"
  end

  def payload(edition)
    {
      details: { name.to_sym => edition.contents[name] }
    }
  end

  def updater_params(_edition, params)
    { contents: { name.to_sym => params[name] || default } }
  end

  def collection_params(params)
    { name.to_sym => params[name] || default }
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

  def value(item)
    option = options.find { |o| o["name"] == item }
    option && option["label"]
  end
end
