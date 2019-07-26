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

      form_message = issues.items_for(:access_limit).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.access_limit.no_primary_org.form_message"))
    end

    context "when edition is access limited to some orgs" do
      let(:edition) { build(:edition, :access_limited, created_by: user) }

      it "returns an issue when the user is not in the orgs" do
        allow(edition.access_limit).to receive(:organisation_ids) { %w[another-org] }
        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        form_message = issues.items_for(:access_limit).first[:text]
        expect(form_message).to eq(I18n.t!("requirements.access_limit.not_in_orgs.form_message"))
      end

      it "returns no issues when the user is in the orgs" do
        allow(edition.access_limit).to receive(:organisation_ids) { %w[my-org] }
        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        expect(issues).to be_empty
      end
    end
  end
end
