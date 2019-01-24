# frozen_string_literal: true

RSpec.describe DocumentTopics do
  include TopicsHelper

  before { stub_publishing_api_has_taxonomy }

  describe ".find_by_document" do
    context "when we can access topics" do
      it "returns an object with the topics" do
        document = build(:document)
        stub_publishing_api_has_links(
          "content_id" => document.content_id,
          "links" => {
            "taxons" => %w(level_one_topic),
          },
          "version" => 1,
        )

        document_topics = DocumentTopics.find_by_document(document, TopicIndexService.new)

        expect(document_topics.version).to eq(1)
        expect(document_topics.document).to be(document)
        expect(document_topics.topics.first&.content_id).to eq("level_one_topic")
      end
    end

    context "when topics for a document don't exist" do
      it "returns an empty object" do
        document = build(:document)
        stub_publishing_api_does_not_have_links(document.content_id)
        document_topics = DocumentTopics.find_by_document(document, TopicIndexService.new)

        expect(document_topics.version).to be_nil
        expect(document_topics.document).to be(document)
        expect(document_topics.topics).to be_empty
      end
    end
  end
end
