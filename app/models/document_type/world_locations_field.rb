class DocumentType::WorldLocationsField
  def id
    "world_locations"
  end

  def payload(edition)
    return {} if edition.tags[id].blank?

    { links: { id.to_sym => edition.tags[id] } }
  end

  def updater_params(_edition, params)
    { world_locations: params[:world_locations] }
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end

  def pre_preview_issues(_edition)
    Requirements::CheckerIssues.new
  end

  def pre_publish_issues(_edition)
    Requirements::CheckerIssues.new
  end
end
