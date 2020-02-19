class DocumentType::RoleAppointmentsField
  def id
    "role_appointments"
  end

  def type
    "multi_tag"
  end

  def document_type
    "role_appointment"
  end

  def pre_update_issues(_edition, _params)
    Requirements::CheckerIssues.new
  end
end
