# frozen_string_literal: true

RSpec.describe EditionAssertions do
  include EditionAssertions

  describe "#assert_edition_state" do
    let(:edition) { build :edition }

    it "does nothing when the assertion block returns true" do
      expect { assert_edition_state(edition) { true } }.to_not raise_error
    end

    it "raises an error when the assertion block is false" do
      expect { assert_edition_state(edition) { false } }
        .to raise_error(EditionAssertions::StateError)
    end

    it "can raise errors with custom messaging" do
      expect { assert_edition_state(edition, assertion: "custom messaging") { false } }
        .to raise_error(EditionAssertions::StateError, /custom messaging/)
    end
  end

  describe "#assert_edition_access" do
    let(:user) { build :user, organisation_content_id: "primary-org-id" }

    it "does nothing when the edition is not access limited" do
      edition = build :edition, created_by: user
      expect { assert_edition_access(edition, user) }.to_not raise_error
    end

    context "when access is limited to the primary org" do
      let(:edition) do
        build :edition, :access_limited, limit_type: :primary_organisation, created_by: user
      end

      it "does nothing when the user is in the primary org" do
        expect { assert_edition_access(edition, user) }.to_not raise_error
      end

      it "raises an error when the user is in another org" do
        another_user = build :user, organisation_content_id: "another-org"

        expect { assert_edition_access(edition, another_user) }
          .to raise_error(EditionAssertions::AccessError)
      end
    end

    context "when access is limited to supporting orgs" do
      let(:edition) do
        build :edition,
              :access_limited,
              limit_type: :all_organisations,
              tags: {
                primary_publishing_organisation: %w[primary-org-id],
                organisations: %w[primary-org-id supporting-org-id],
              }
      end

      it "does nothing when the user is in the primary org" do
        expect { assert_edition_access(edition, user) }.to_not raise_error
      end

      it "does nothing when the user is in a supporting org" do
        supporting_user = build :user, organisation_content_id: "supporting-org-id"
        expect { assert_edition_access(edition, supporting_user) }.to_not raise_error
      end

      it "raises an error when the user is in another org" do
        another_user = build :user, organisation_content_id: "another-org"

        expect { assert_edition_access(edition, another_user) }
          .to raise_error(EditionAssertions::AccessError)
      end
    end
  end
end
