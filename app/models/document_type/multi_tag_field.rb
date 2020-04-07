class DocumentType::MultiTagField
  def payload
    raise "not implemented"
  end

  def updater_params(_edition, params)
    { id.to_sym => params[id.to_sym] }.compact
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end

  def pre_preview_issues(_edition)
    Requirements::CheckerIssues.new
  end

  def pre_publish_issues(_edition)
    Requirements::CheckerIssues.new
  end
end
