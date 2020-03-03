class DocumentType::OrganisationsField < DocumentType::MultiTagField
  def id
    "organisations"
  end

  def payload(edition)
    links = edition.tags["primary_publishing_organisation"].to_a + edition.tags[id].to_a
    { links: { id.to_sym => links.uniq } }
  end
end
