# frozen_string_literal: true

RSpec.describe AccessLimit do
  describe "#organisation_ids" do
    context "when the limit is to primary orgs" do
      let(:edition) do
        build(:edition,
              :access_limited,
              limit_type: :primary_organisation,
              tags: {
                primary_publishing_organisation: %w[primary-org],
                organisations: %w[supporting-org],
              })
      end

      it "returns just the primary org id" do
        ids = edition.access_limit.organisation_ids
        expect(ids).to eq(%w[primary-org])
      end
    end

    context "when the limit is to tagged orgs" do
      let(:edition) do
        build(:edition,
              :access_limited,
              limit_type: :tagged_organisations,
              tags: {
                primary_publishing_organisation: %w[primary-org],
                organisations: %w[supporting-org],
              })
      end

      it "returns the primary and supporting orgs" do
        ids = edition.access_limit.organisation_ids
        expect(ids).to match_array(%w[primary-org supporting-org])
      end
    end
  end
end
