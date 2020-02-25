class DocumentType::OrganisationsField
  def id
    "organisations"
  end

  def document_type
    "organisation"
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end
end
