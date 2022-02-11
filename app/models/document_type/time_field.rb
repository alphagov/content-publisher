class DocumentType::TimeField
  attr_reader :name, :label, :precision

  def initialize(options)
    @name = options.fetch("name")
    @label = options.fetch("label")
    @precision = options.fetch("precision")
  end

  def id
    "time"
  end

  def payload(edition)
    {
      details: { name.to_sym => edition.contents[name] }
    }
  end

  def updater_params(_edition, params)
    { contents: collection_params(params) }
  end

  def collection_params(params)
    value = if params[name].nil?
              nil
            elsif precision == "date"
              day, month, year = params[name].values_at(:day, :month, :year)
              Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
            else
              # @TODO
              # Time.parse(params[name])
              Time.now
            end

    { name.to_sym => value }
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
