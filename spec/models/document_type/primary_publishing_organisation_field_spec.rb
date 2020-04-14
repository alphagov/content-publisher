RSpec.describe DocumentType::PrimaryPublishingOrganisationField do
  describe "#payload" do
    it "returns a hash with 'primary_publishing_organisation'" do
      org_ids = [SecureRandom.uuid]
      edition = build(:edition, tags: { primary_publishing_organisation: org_ids })
      payload = described_class.new.payload(edition)
      expect(payload[:links][:primary_publishing_organisation]).to eq(org_ids)
    end
  end

  describe "#updater_params" do
    it "returns a hash of the primary_publishing_organisations" do
      edition = build :edition
      params = ActionController::Parameters.new(primary_publishing_organisation: %w[some_org_id])
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(primary_publishing_organisation: %w[some_org_id])
    end

    it "copes with empty values for the organisation ID" do
      edition = build :edition
      params = ActionController::Parameters.new(primary_publishing_organisation: [""])
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(primary_publishing_organisation: %w[])
    end

    it "copes when the field is not present in the params" do
      edition = build :edition
      params = ActionController::Parameters.new
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq({})
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

  describe "#pre_preview_issues" do
    it "delegates to #pre_update_issues" do
      field = described_class.new
      expect(field).to receive(:pre_update_issues)
      field.pre_preview_issues(build(:edition))
    end
  end
end
