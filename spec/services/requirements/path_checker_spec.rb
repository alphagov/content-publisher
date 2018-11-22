# frozen_string_literal: true

RSpec.describe Requirements::PathChecker do
  describe "#pre_preview_issues" do
    context "when the format does not check paths" do
      it "returns no issues" do
        schema = build :document_type_schema
        document = build :document, document_type: schema.id
        issues = Requirements::PathChecker.new(document).pre_preview_issues
        expect(issues.items).to be_empty
      end
    end

    context "when the Publishing API is available" do
      it "returns no issues for unreserved paths" do
        schema = build :document_type_schema, check_path_conflict: true
        document = build :document, document_type: schema.id
        publishing_api_has_lookups(document.base_path => nil)
        issues = Requirements::PathChecker.new(document).pre_preview_issues
        expect(issues.items).to be_empty
      end

      it "returns no issues if the document owns the path" do
        schema = build :document_type_schema, check_path_conflict: true
        document = build :document, document_type: schema.id
        publishing_api_has_lookups(document.base_path => document.content_id)
        issues = Requirements::PathChecker.new(document).pre_preview_issues
        expect(issues.items).to be_empty
      end

      it "returns an issue if the base_path conflicts" do
        schema = build :document_type_schema, check_path_conflict: true
        document = build :document, document_type: schema.id
        publishing_api_has_lookups(document.base_path => SecureRandom.uuid)
        issues = Requirements::PathChecker.new(document).pre_preview_issues

        form_message = issues.items_for(:base_path).first[:text]
        expect(form_message).to eq(I18n.t!("requirements.base_path.conflict.form_message"))

        summary_message = issues.items_for(:base_path, style: "summary").first[:text]
        expect(summary_message).to eq(I18n.t!("requirements.base_path.conflict.summary_message"))
      end
    end

    context "when the Publishing API is down" do
      before do
        # TODO: add this stub as part of the V2 helpers
        stub_request(:post, GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT + "/lookup-by-base-path")
          .to_return(status: 503)
      end

      it "returns no issues by default (ignore exception)" do
        publishing_api_isnt_available
        schema = build :document_type_schema, check_path_conflict: true
        document = build :document, document_type: schema.id
        issues = Requirements::PathChecker.new(document).pre_preview_issues
        expect(issues.items_for(:base_path)).to be_empty
      end

      it "raises an exception if we specify it should" do
        schema = build :document_type_schema, check_path_conflict: true
        document = build :document, document_type: schema.id

        expect { Requirements::PathChecker.new(document).pre_preview_issues(rescue_api_errors: false) }
          .to raise_error GdsApi::BaseError
      end
    end
  end
end
