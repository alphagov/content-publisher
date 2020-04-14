class DocumentType::PrimaryPublishingOrganisationField
  def id
    "primary_publishing_organisation"
  end

  def payload(edition)
    { links: { id.to_sym => edition.tags[id] } }
  end

  def updater_params(_edition, params)
    value = params[id] && params[id].map(&:presence).compact
    { id.to_sym => value }.compact
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
end
