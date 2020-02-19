class DocumentType::TopicalEventsField
  def id
    "topical_events"
  end

  def type
    "multi_tag"
  end

  def document_type
    "topical_event"
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end
end
