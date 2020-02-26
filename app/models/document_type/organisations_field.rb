class DocumentType::OrganisationsField
  def id
    "organisations"
  end

  def payload(edition)
    links = edition.tags["primary_publishing_organisation"].to_a + edition.tags[id].to_a
    { links: { id.to_sym => links.uniq } }
  end

  def updater_params(_edition, params)
    { organisations: params[:organisations] }
  end

  def document_type
    "organisation"
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end

  def pre_publish_issues(_edition)
    Requirements::CheckerIssues.new
  end
end
