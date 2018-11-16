# frozen_string_literal: true

RSpec.describe Requirements::TopicChecker do
  include TopicsHelper

  describe "#pre_publish_issues" do
    it "returns no issues if there are none" do
      document = build :document, :with_required_content_for_publishing
      issues = Requirements::TopicChecker.new(document).pre_publish_issues
      expect(issues.items).to be_empty
    end

    context "when the Publishing API is available" do
      let(:schema) { build :document_type_schema, topics: true }
      let(:document) { build :document, document_type: schema.id }

      before do
        publishing_api_has_links(
          "content_id" => document.content_id,
          "links" => {},
          "version" => 3,
        )

        publishing_api_has_taxonomy
      end

      it "returns an issue if there are no topics" do
        issues = Requirements::TopicChecker.new(document).pre_publish_issues

        short_message = issues.items_for(:topics).first[:text]
        expect(short_message).to eq(I18n.t!("requirements.topics.none.short_message"))

        long_message = issues.items_for(:topics, verbose: true).first[:text]
        expect(long_message).to eq(I18n.t!("requirements.topics.none.long_message"))
      end
    end

    context "when the Publishing API is down" do
      let(:schema) { build :document_type_schema, topics: true }
      let(:document) { build :document, document_type: schema.id }

      before do
        publishing_api_isnt_available
      end

      it "returns no issues by default (ignore exception)" do
        issues = Requirements::TopicChecker.new(document).pre_publish_issues
        expect(issues.items_for(:topics)).to be_empty
      end

      it "raises an exception if we specify it should" do
        expect { Requirements::TopicChecker.new(document).pre_publish_issues(raise_exceptions: true) }
          .to raise_error GdsApi::BaseError
      end
    end
  end
end
