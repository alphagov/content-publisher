RSpec.describe DocumentType::RoleAppointmentsField do
  describe "#payload" do
    it "converts role appointment links to role and person links" do
      role_appointment_id = SecureRandom.uuid
      person_id = SecureRandom.uuid
      role_id = SecureRandom.uuid
      stub_publishing_api_has_links(
        content_id: role_appointment_id,
        links: { person: [person_id], role: [role_id] },
      )

      edition = build(:edition, tags: { role_appointments: [role_appointment_id] })
      payload = described_class.new.payload(edition)
      expect(payload).to match a_hash_including(
        links: {
          roles: [role_id],
          people: [person_id],
        },
      )
    end
  end
end
