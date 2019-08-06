# frozen_string_literal: true

RSpec.describe Requirements::AccessLimitChecker do
  describe "#pre_update_issues" do
    let(:user) { build :user, organisation_content_id: "my-org" }

    it "returns no issues when there is no access limit" do
      edition = build(:edition)
      issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
      expect(issues).to be_empty
    end

    it "returns an issue when the edition has no primary org" do
      edition = build(:edition, :access_limited)
      issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
      expect(issues).to have_issue(:access_limit, :no_primary_org)
    end

    context "when edition is access limited to some orgs" do
      let(:edition) { build(:edition, :access_limited, created_by: user) }

      it "returns an issue when the user is not in the orgs" do
        allow(edition).to receive(:access_limit_organisation_ids) { %w[another-org] }
        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        expect(issues).to have_issue(:access_limit, :not_in_orgs)
      end

      it "returns no issues when the user is in the orgs" do
        allow(edition).to receive(:access_limit_organisation_ids) { %w[my-org] }
        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        expect(issues).to be_empty
      end
    end

    context "when user has no organisation associated with account" do
      let(:user) { build(:user, organisation_content_id: nil) }

      it "returns an issue when the user is not in the orgs" do
        edition = build(:edition, :access_limited, created_by: user)
        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        expect(issues).to have_issue(:access_limit, :user_has_no_org)
      end
    end
  end
end
