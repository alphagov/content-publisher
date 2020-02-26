RSpec.describe DocumentType::OrganisationsField do
  describe "#payload" do
    it "returns a hash with 'organisations'" do
      org_ids = [SecureRandom.uuid, SecureRandom.uuid]
      edition = build(:edition, tags: { organisations: org_ids })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:organisations]).to eq(org_ids)
    end

    it "includes primary publishing organisations" do
      primary_org_ids = [SecureRandom.uuid]
      other_org_ids = [SecureRandom.uuid, SecureRandom.uuid]
      edition = build(:edition,
                      tags: {
                        primary_publishing_organisation: primary_org_ids,
                        organisations: other_org_ids,
                      })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:organisations]).to eq(primary_org_ids + other_org_ids)
    end

    it "filters out duplicate organisation IDs" do
      org_ids = [SecureRandom.uuid, SecureRandom.uuid]
      edition = build(:edition,
                      tags: {
                        primary_publishing_organisation: [org_ids.first],
                        organisations: org_ids,
                      })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:organisations]).to eq(org_ids)
    end
  end

  describe "#updater_params" do
    it "returns a hash of the organisations" do
      edition = build :edition
      params = ActionController::Parameters.new(organisations: %w[some_org_id])
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(organisations: %w[some_org_id])
    end
  end
end
