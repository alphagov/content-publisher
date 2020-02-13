RSpec.describe Requirements::TagChecker do
  describe "#pre_update_issues" do
    it "returns no issues when there are none" do
      edition = build(:edition)
      issues = described_class.new(edition).pre_update_issues({})
      expect(issues.items).to be_empty
    end

    context "when the edition supports primary orgs" do
      let(:edition) do
        organisation_field = build(:tag_field, :primary_publishing_organisation)
        document_type = build(:document_type, tags: [organisation_field])
        build(:edition, document_type: document_type)
      end

      it "returns an issue when the primary org is blank" do
        issues = described_class.new(edition).pre_update_issues({})

        expect(issues).to have_issue(:primary_publishing_organisation,
                                     :blank,
                                     styles: %i[form summary])
      end

      it "returns no issues when there is a primary org" do
        params = { primary_publishing_organisation: %w[my-org] }
        issues = described_class.new(edition).pre_update_issues(params)
        expect(issues.items).to be_empty
      end
    end
  end

  describe "#pre_publish_issues" do
    it "delegates to #pre_update_issues" do
      edition = build :edition, tags: { tag: %w[id1 id2] }
      checker = described_class.new(edition)
      expect(checker).to receive(:pre_update_issues).with(tag: %w[id1 id2])
      checker.pre_publish_issues
    end
  end
end
