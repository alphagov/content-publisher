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
end
