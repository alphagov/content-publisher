class DocumentType::PrimaryPublishingOrganisationField
  def id
    "primary_publishing_organisation"
  end

  def payload(edition)
    { links: { id.to_sym => edition.tags[id] } }
  end

  def updater_params(_edition, params)
    { primary_publishing_organisation: params[:primary_publishing_organisation] }
  end

  def pre_update_issues(_edition, params)
    issues = Requirements::CheckerIssues.new

    if params[:primary_publishing_organisation].blank?
      issues.create(:primary_publishing_organisation, :blank)
    end

    issues
  end

  def pre_preview_issues(edition)
    pre_update_issues(edition, edition.tags.symbolize_keys)
  end

  def pre_publish_issues(edition)
    pre_update_issues(edition, edition.tags.symbolize_keys)
  end
end
