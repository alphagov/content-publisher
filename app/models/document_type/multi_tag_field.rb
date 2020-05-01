class DocumentType::MultiTagField
  def payload
    raise "not implemented"
  end

  def updater_params(_edition, params)
    { id.to_sym => params[id.to_sym] }.compact
  end

  def form_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end

  def preview_issues(_edition)
    Requirements::CheckerIssues.new
  end
end
