class DocumentType::TopicalEventsField < DocumentType::MultiTagField
  def id
    "topical_events"
  end

  def payload(edition)
    return {} if edition.tags[id].blank?

    { links: { id.to_sym => edition.tags[id] } }
  end
end
