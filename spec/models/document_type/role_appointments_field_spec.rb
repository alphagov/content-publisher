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

  describe "#updater_params" do
    it "returns a hash of the role_appointments" do
      edition = build :edition
      params = ActionController::Parameters.new(role_appointments: %w[some_role_id])
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(role_appointments: %w[some_role_id])
    end

    it "disallows incorect data" do
      edition = build :edition
      params = ActionController::Parameters.new(organisations: nil)
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to be_empty
    end
  end
end
