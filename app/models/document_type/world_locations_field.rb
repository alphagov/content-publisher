class DocumentType::WorldLocationsField < DocumentType::MultiTagField
  def id
    "world_locations"
  end

  def payload(edition)
    return {} if edition.tags[id].blank?

    { links: { id.to_sym => edition.tags[id] } }
  end
end
