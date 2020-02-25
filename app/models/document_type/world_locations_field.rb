class DocumentType::WorldLocationsField
  def id
    "world_locations"
  end

  def payload(edition)
    return {} if edition.tags[id].blank?

    { links: { id.to_sym => edition.tags[id] } }
  end

  def document_type
    "world_location"
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end
end
