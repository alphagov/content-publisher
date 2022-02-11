class DocumentType::ChooseMultipleField
  attr_reader :name, :label, :options

  def initialize(options)
    @name = options.fetch("name")
    @label = options.fetch("label")
    @options = options.fetch("options")
  end

  def id
    "choose_multiple"
  end

  def payload(edition)
    {
      details: { name.to_sym => edition.contents[name] }
    }
  end

  def updater_params(_edition, params)
    { contents: { name.to_sym => params[name] } }
  end

  def collection_params(params)
    { name.to_sym => params[name] }
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

  def values(items)
    return [] unless items.respond_to?(:filter_map)

    items.filter_map do |i|
      option = options.find { |o| o["name"] == i }
      option && option["label"]
    end
  end
end
