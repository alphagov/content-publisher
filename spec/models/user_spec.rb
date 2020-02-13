RSpec.describe User do
  describe "#can_access?" do
    context "when the user has an override permission" do
      it "returns true" do
        user = build(:user, permissions: [
          User::ACCESS_LIMIT_OVERRIDE_PERMISSION,
        ])

        edition = build(:edition)
        expect(user).to be_can_access(edition)
      end
    end

    context "when the edition is access limited" do
      let(:edition) { build(:edition, :access_limited) }

      before do
        allow(edition).to receive(:access_limit_organisation_ids).and_return(%w[org-id])
      end

      it "returns true if the user is in the specified orgs" do
        user = build(:user, organisation_content_id: "org-id")
        expect(user).to be_can_access(edition)
      end

      it "returns false if the user is not in the orgs" do
        user = build(:user, organisation_content_id: "another-org-id")
        expect(user).not_to be_can_access(edition)
      end
    end

    context "when the edition is not access limited" do
      it "returns true" do
        edition = build(:edition)
        user = build(:user)
        expect(user).to be_can_access(edition)
      end
    end
  end
end
