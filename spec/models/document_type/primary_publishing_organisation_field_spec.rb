RSpec.describe DocumentType::PrimaryPublishingOrganisationField do
  describe "#payload" do
    it "returns a hash with 'primary_publishing_organisation'" do
      org_ids = [SecureRandom.uuid]
      edition = build(:edition, tags: { primary_publishing_organisation: org_ids })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:primary_publishing_organisation]).to eq(org_ids)
    end
  end

  describe "#pre_update_issues" do
    let(:edition) { build(:edition) }

    it "returns no issues when there are none" do
      params = { primary_publishing_organisation: SecureRandom.uuid }
      issues = described_class.new.pre_update_issues(edition, params)
      expect(issues).to be_empty
    end

    it "returns an issue if no primary publishing organisation is provided" do
      params = {}
      issues = described_class.new.pre_update_issues(edition, params)
      expect(issues).to have_issue(:primary_publishing_organisation, :blank, styles: %i[form summary])
    end
  end
end
