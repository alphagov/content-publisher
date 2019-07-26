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

    context "when the edition is access limited to some orgs" do
      let(:edition) { build(:edition, :access_limited) }

      it "does nothing when the user is in the orgs" do
        allow(edition.access_limit).to receive(:organisation_ids) { %w[primary-org-id] }
        expect { assert_edition_access(edition, user) }.to_not raise_error
      end

      it "raises an error when the user is not in the orgs" do
        allow(edition.access_limit).to receive(:organisation_ids) { %w[another-org-id] }

        expect { assert_edition_access(edition, user) }
          .to raise_error(EditionAssertions::AccessError)
      end
    end
  end
end
