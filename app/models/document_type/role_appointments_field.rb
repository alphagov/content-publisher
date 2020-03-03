class DocumentType::RoleAppointmentsField < DocumentType::MultiTagField
  def id
    "role_appointments"
  end

  def payload(edition)
    role_appointments = edition.tags[id]
    return {} if !role_appointments || role_appointments.count.zero?

    roles_and_people = role_appointments
      .each_with_object(roles: [], people: []) do |appointment_id, memo|
        response = GdsApi.publishing_api.get_links(appointment_id).to_hash

        roles = response.dig("links", "role") || []
        people = response.dig("links", "person") || []

        memo[:roles] = (memo[:roles] + roles).uniq
        memo[:people] = (memo[:people] + people).uniq
      end
    { links: roles_and_people }
  end
end
