# frozen_string_literal: true

RSpec.describe Requirements::DocumentChecker do
  include TopicsHelper

  describe "#pre_draft_issues" do
    it "returns no issues if there are none" do
      document = build :document
      issues = Requirements::DocumentChecker.new(document).pre_draft_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if there is no title" do
      document = build :document, title: nil
      issues = Requirements::DocumentChecker.new(document).pre_draft_issues

      short_message = issues.items_for(:title).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.title.blank.short_message"))

      long_message = issues.items_for(:title, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.title.blank.long_message"))
    end

    it "returns an issue if the title is too long" do
      max_length = Requirements::DocumentChecker::TITLE_MAX_LENGTH
      document = build :document, title: "a" * (max_length + 1)
      issues = Requirements::DocumentChecker.new(document).pre_draft_issues

      short_message = issues.items_for(:title).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.title.too_long.short_message", max_length: max_length))

      long_message = issues.items_for(:title, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.title.too_long.long_message", max_length: max_length))
    end

    it "returns an issue if the title has newlines" do
      document = build :document, title: "a\nb"
      issues = Requirements::DocumentChecker.new(document).pre_draft_issues

      short_message = issues.items_for(:title).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.title.multiline.short_message"))

      long_message = issues.items_for(:title, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.title.multiline.long_message"))
    end
  end

  describe "#pre_publish_issues" do
    it "returns no issues if there are none" do
      document = build :document, :with_required_content_for_publishing
      issues = Requirements::DocumentChecker.new(document).pre_publish_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if the summary is blank" do
      document = build :document
      issues = Requirements::DocumentChecker.new(document).pre_publish_issues

      short_message = issues.items_for(:summary).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.summary.blank.short_message"))

      long_message = issues.items_for(:summary, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.summary.blank.long_message"))
    end

    it "returns an issue if a field is blank" do
      schema = build :document_type_schema, contents: [(build :field_schema, id: "body")]
      document = build :document, document_type: schema.id
      issues = Requirements::DocumentChecker.new(document).pre_publish_issues

      short_message = issues.items_for(:body).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.body.blank.short_message"))

      long_message = issues.items_for(:body, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.body.blank.long_message"))
    end

    it "returns an issue if a major change note is blank" do
      document = build :document, has_live_version_on_govuk: true
      issues = Requirements::DocumentChecker.new(document).pre_publish_issues

      short_message = issues.items_for(:change_note).first[:text]
      expect(short_message).to eq(I18n.t!("requirements.change_note.blank.short_message"))

      long_message = issues.items_for(:change_note, verbose: true).first[:text]
      expect(long_message).to eq(I18n.t!("requirements.change_note.blank.long_message"))
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
        issues = Requirements::DocumentChecker.new(document).pre_publish_issues

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
        issues = Requirements::DocumentChecker.new(document).pre_publish_issues
        expect(issues.items_for(:topics)).to be_empty
      end

      it "raises an exception if we specify it should" do
        expect { Requirements::DocumentChecker.new(document).pre_publish_issues(raise_exceptions: true) }
          .to raise_error GdsApi::BaseError
      end
    end
  end
end
