# frozen_string_literal: true

RSpec.describe Requirements::TagChecker do
  describe "#pre_publish_issues" do
    it "returns no issues when there are none" do
      edition = build(:edition)
      issues = Requirements::TagChecker.new(edition).pre_publish_issues
      expect(issues.items).to be_empty
    end

    context "when the edition supports primary orgs" do
      let(:document_type) do
        organisation_field = build(:tag_field,
                                   type: "single_tag",
                                   id: "primary_publishing_organisation")

        build(:document_type, tags: [organisation_field])
      end

      it "returns an issue when the primary org is blank" do
        edition = build(:edition, document_type_id: document_type.id)
        issues = Requirements::TagChecker.new(edition).pre_publish_issues

        form_message = issues
          .items_for(:primary_publishing_organisation)
          .first[:text]

        expect(form_message).to eq(
          I18n.t!("requirements.primary_publishing_organisation.blank.form_message"),
        )

        summary_message = issues
          .items_for(:primary_publishing_organisation, style: :summary)
          .first[:text]

        expect(summary_message).to eq(
          I18n.t!("requirements.primary_publishing_organisation.blank.summary_message"),
        )
      end

      it "returns no issues when there is a primary org" do
        edition = build(:edition,
                        document_type_id: document_type.id,
                        tags: {
                          primary_publishing_organisation: %w[my-org],
                        })

        issues = Requirements::TagChecker.new(edition).pre_publish_issues
        expect(issues.items).to be_empty
      end
    end
  end
end
