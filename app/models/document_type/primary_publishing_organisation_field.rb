class DocumentType::PrimaryPublishingOrganisationField
  def id
    "primary_publishing_organisation"
  end

  def payload(edition)
    { links: { id.to_sym => edition.tags[id] } }
  end

  def document_type
    "organisation"
  end

  def pre_update_issues(_edition, params)
    issues = Requirements::CheckerIssues.new

    if params[:primary_publishing_organisation].blank?
      issues.create(:primary_publishing_organisation, :blank)
    end

    issues
  end
end
