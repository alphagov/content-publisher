# frozen_string_literal: true

RSpec.describe Requirements::AccessLimitChecker do
  describe "#pre_update_issues" do
    let(:user) { build :user, organisation_content_id: "my-org" }

    it "returns no issues when there is no access limit" do
      edition = build(:edition)
      issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue when the edition has no primary org" do
      edition = build(:edition, :access_limited)
      issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues

      form_message = issues.items_for(:access_limit).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.access_limit.no_primary_org.form_message"))
    end

    context "the access limit is for the primary org" do
      it "returns an issue when the user is not in the org" do
        edition = build(:edition,
                        :access_limited,
                        limit_type: :primary_organisation,
                        tags: {
                          primary_publishing_organisation: %w[another-org],
                        })

        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        form_message = issues.items_for(:access_limit).first[:text]
        expect(form_message).to eq(I18n.t!("requirements.access_limit.not_in_orgs.form_message"))
      end

      it "returns no issues when the user is in the org" do
        edition = build(:edition,
                        :access_limited,
                        limit_type: :primary_organisation,
                        tags: {
                          primary_publishing_organisation: %w[my-org],
                        })

        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        expect(issues.items).to be_empty
      end
    end

    context "the access limit is for tagged orgs" do
      it "returns an issue when the user is not in any of the orgs" do
        edition = build(:edition,
                        :access_limited,
                        limit_type: :tagged_organisations,
                        tags: {
                          primary_publishing_organisation: %w[another-org],
                          organisations: %w[supporting-org],
                        })

        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        form_message = issues.items_for(:access_limit).first[:text]
        expect(form_message).to eq(I18n.t!("requirements.access_limit.not_in_orgs.form_message"))
      end

      it "returns no issues when the user is in a supporting org" do
        edition = build(:edition,
                        :access_limited,
                        limit_type: :tagged_organisations,
                        tags: {
                          primary_publishing_organisation: %w[another-org],
                          organisations: %w[my-org],
                        })

        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        expect(issues.items).to be_empty
      end

      it "returns no issues when the user is in the primary org" do
        edition = build(:edition,
                        :access_limited,
                        limit_type: :tagged_organisations,
                        tags: {
                          primary_publishing_organisation: %w[my-org],
                          organisations: %w[supporting-org],
                        })

        issues = Requirements::AccessLimitChecker.new(edition, user).pre_update_issues
        expect(issues.items).to be_empty
      end
    end
  end
end
