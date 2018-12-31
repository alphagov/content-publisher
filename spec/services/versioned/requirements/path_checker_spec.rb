# frozen_string_literal: true

RSpec.describe Versioned::Requirements::PathChecker do
  describe "#pre_preview_issues" do
    context "when the format does not check paths" do
      it "returns no issues" do
        document_type = build :document_type
        edition = build :versioned_edition, document_type_id: document_type.id
        issues = Versioned::Requirements::PathChecker.new(edition).pre_preview_issues
        expect(issues.items).to be_empty
      end
    end

    context "when the Publishing API is available" do
      it "returns no issues for unreserved paths" do
        document_type = build :document_type, check_path_conflict: true
        edition = build :versioned_edition, document_type_id: document_type.id
        publishing_api_has_lookups(edition.base_path => nil)
        issues = Versioned::Requirements::PathChecker.new(edition).pre_preview_issues
        expect(issues.items).to be_empty
      end

      it "returns no issues if the document owns the path" do
        document_type = build :document_type, check_path_conflict: true
        edition = build :versioned_edition, document_type_id: document_type.id
        publishing_api_has_lookups(edition.base_path => edition.content_id)
        issues = Versioned::Requirements::PathChecker.new(edition).pre_preview_issues
        expect(issues.items).to be_empty
      end

      it "returns an issue if the base_path conflicts" do
        document_type = build :document_type, check_path_conflict: true
        edition = build :versioned_edition, document_type_id: document_type.id
        publishing_api_has_lookups(edition.base_path => SecureRandom.uuid)
        issues = Versioned::Requirements::PathChecker.new(edition).pre_preview_issues

        form_message = issues.items_for(:title).first[:text]
        expect(form_message).to eq(I18n.t!("requirements.title.conflict.form_message"))

        summary_message = issues.items_for(:title, style: "summary").first[:text]
        expect(summary_message).to eq(I18n.t!("requirements.title.conflict.summary_message"))
      end

      it "can check a revision" do
        document_type = build :document_type, check_path_conflict: true
        edition = build :versioned_edition, document_type_id: document_type.id
        revision = build :versioned_revision
        publishing_api_has_lookups(edition.base_path => nil,
                                   revision.base_path => SecureRandom.uuid)
        issues = Versioned::Requirements::PathChecker.new(edition).pre_preview_issues
        expect(issues.items).to be_empty

        issues = Versioned::Requirements::PathChecker.new(edition, revision)
                                                     .pre_preview_issues
        expect(issues.items).not_to be_empty
      end
    end

    context "when the Publishing API is down" do
      before do
        publishing_api_isnt_available
      end

      it "returns no issues (ignore exception)" do
        document_type = build :document_type, check_path_conflict: true
        edition = build :versioned_edition, document_type_id: document_type.id
        issues = Versioned::Requirements::PathChecker.new(edition).pre_preview_issues
        expect(issues.items_for(:title)).to be_empty
      end
    end
  end
end
