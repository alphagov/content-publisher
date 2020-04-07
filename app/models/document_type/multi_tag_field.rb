class DocumentType::MultiTagField
  def payload(edition)
    return {} if edition.tags[id].blank?

    { links: { id.to_sym => edition.tags[id] } }
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
end
