class DocumentType::TopicalEventsField
  def id
    "topical_events"
  end

  def payload(edition)
    return {} if edition.tags[id].blank?

    { links: { id.to_sym => edition.tags[id] } }
  end

  def updater_params(_edition, params)
    { topical_events: params[:topical_events] }
  end

  def document_type
    "topical_event"
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end

  def pre_preview_issues(_edition)
    Requirements::CheckerIssues.new
  end

  def pre_publish_issues(edition)
    pre_update_issues(edition, edition.tags.symbolize_keys)
  end
end
