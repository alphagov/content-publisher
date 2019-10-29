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

        document_topics = DocumentTopics.find_by_document(document, TopicIndex.new)

        expect(document_topics.version).to eq(1)
        expect(document_topics.document).to be(document)
        expect(document_topics.topics.first&.content_id).to eq("level_one_topic")
      end
    end

    context "when topics for a document don't exist" do
      it "returns an empty object" do
        document = build(:document)
        stub_publishing_api_does_not_have_links(document.content_id)
        document_topics = DocumentTopics.find_by_document(document, TopicIndex.new)

        expect(document_topics.version).to be_nil
        expect(document_topics.document).to be(document)
        expect(document_topics.topics).to be_empty
      end
    end

    context "when it contains topics that are not in the single taxonomy" do
      it "removes the unknown topics from the object" do
        document = build(:document)
        stub_publishing_api_has_links(
          "content_id" => document.content_id,
          "links" => {
            "taxons" => %w(level_one_topic unknown_taxon_content_id),
          },
          "version" => 1,
        )

        document_topics = DocumentTopics.find_by_document(document, TopicIndex.new)

        expect(document_topics.topics.count).to eq(1)
        expect(document_topics.version).to eq(1)
        expect(document_topics.document).to be(document)
        expect(document_topics.topics.first&.content_id).to eq("level_one_topic")
      end
    end
  end

  describe ".patch" do
    before { stub_any_publishing_api_patch_links }

    context "when the document is not tagged to a taxon" do
      it "sets the new selected value" do
        document = build(:document)
        stub_publishing_api_does_not_have_links(document.content_id)

        document.document_topics.patch(%w(level_one_topic), 1)

        expected_links = {
          links: {
            taxons: %w(level_one_topic),
            topics: %w(specialist_sector_1),
          },
          previous_version: 1,
        }

        assert_publishing_api_patch_links(document.content_id, expected_links, 1)
        expect(document.document_topics.topic_content_ids).to eq(%w(level_one_topic))
      end
    end

    context "when a document is already tagged to a taxon" do
      it "replaces the taxon with the new selection" do
        document = build(:document)
        stub_publishing_api_has_links(
          "content_id" => document.content_id,
          "links" => {
            "taxons" => %w(level_one_topic),
          },
          "version" => 1,
        )

        document.document_topics.patch(%w(level_two_topic), 1)

        expected_links = {
          links: {
            taxons: %w(level_two_topic),
            topics: %w(specialist_sector_1 specialist_sector_2),
          },
          previous_version: 1,
        }

        assert_publishing_api_patch_links(document.content_id, expected_links, 1)
        expect(document.document_topics.topic_content_ids).to eq(%w(level_two_topic))
      end
    end

    context "when a document is tagged to taxons not in the single taxonomy" do
      it "does not overwrite the unknown taxons" do
        document = build(:document)
        stub_publishing_api_has_links(
          "content_id" => document.content_id,
          "links" => {
            "taxons" => %w(level_one_topic unknown_taxon_content_id),
          },
          "version" => 1,
        )

        document.document_topics.patch(%w(level_two_topic), 1)

        expected_links = {
          links: {
            taxons: %w(level_two_topic unknown_taxon_content_id),
            topics: %w(specialist_sector_1 specialist_sector_2),
          },
          previous_version: 1,
        }

        assert_publishing_api_patch_links(document.content_id, expected_links, 1)
        expect(document.document_topics.topic_content_ids).to eq(%w(level_two_topic unknown_taxon_content_id))
      end
    end
  end
end
