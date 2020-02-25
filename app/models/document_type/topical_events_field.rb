class DocumentType::TopicalEventsField
  def id
    "topical_events"
  end

  def payload(edition)
    return {} if edition.tags[id].blank?

    { links: { id.to_sym => edition.tags[id] } }
  end

  def document_type
    "topical_event"
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end
end
