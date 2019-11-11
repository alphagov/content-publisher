# frozen_string_literal: true

RSpec.describe SuggestTopicsService::SuggestedTopic do
  include TopicsHelper

  describe "#topic" do
    let(:edition) { create(:edition) }

    before do
      stub_publishing_api_has_taxonomy
    end

    it "has a topic with the correct content_id" do
      topic_content_id = "level_three_topic"
      suggestion = { "taxon_content_id" => topic_content_id, "explanation" => %i(word) }
      suggested_topic = SuggestTopicsService::SuggestedTopic.new(suggestion, 0)
      expect(suggested_topic.topic.content_id).to eq(topic_content_id)
    end
  end

  describe "#modal_id" do
    let(:edition) { create(:edition) }

    before do
      stub_publishing_api_has_taxonomy
    end

    it "the modal_id contains the topic content_id" do
      topic_content_id = "level_three_topic"
      suggestion = { "taxon_content_id" => topic_content_id, "explanation" => %i(word) }
      suggested_topic = SuggestTopicsService::SuggestedTopic.new(suggestion, 0)
      expect(suggested_topic.modal_id).to eq( "modal-suggestion-#{topic_content_id}")
    end
  end

  describe "#hidden?" do
    let(:edition) { create(:edition) }

    before do
      stub_publishing_api_has_taxonomy
    end

    it "it is not hidden if the index less than 3" do
      topic_content_id = "level_three_topic"
      suggestion = { "taxon_content_id" => topic_content_id, "explanation" => %i(word) }
      suggested_topic = SuggestTopicsService::SuggestedTopic.new(suggestion, 2)
      expect(suggested_topic.hidden?).to be_truthy
    end

    it "it is hidden if the index is equal to 3" do
      topic_content_id = "level_three_topic"
      suggestion = { "taxon_content_id" => topic_content_id, "explanation" => %i(word) }
      suggested_topic = SuggestTopicsService::SuggestedTopic.new(suggestion, 3)
      expect(suggested_topic.hidden?).to be_truthy
    end

    it "it is hidden if the index is greater than 3" do
      topic_content_id = "level_three_topic"
      suggestion = { "taxon_content_id" => topic_content_id, "explanation" => %i(word) }
      suggested_topic = SuggestTopicsService::SuggestedTopic.new(suggestion, 10)
      expect(suggested_topic.hidden?).to be_truthy
    end
  end

  describe "#content" do
    it "can parse the content" do
      document_types = %w(
        answer
        authored_article
        case_study
        closed_consultation
        consultation_outcome
        correspondence
        decision
        detailed_guidance
        detailed_guide
        foi_release
        form
        government_response
        guidance
        guide
        hmrc_manual
        hmrc_manual_section
        html_publication
        manual
        manual_section
        national
        national_statistics
        national_statistics_announcement
        notice
        official
        official_statistics
        official_statistics_announcement
        open_consultation
        petitions_and_campaigns
        policy_area
        policy_paper
        regulation
        research
        services_and_information
        simple_smart_answer
        smart_answer
        statistical_data_set
        statistics
        statistics_announcement
        statutory_guidance
        statutory_instrument
        topical_event
        transaction
        transparency
        travel_advice
      )

      topic_content_id = "level_three_topic"

      params = {
        document_type: document_types,
        link_taxons: topic_content_id,
        per_page: 5,
        fields: %w(title description base_path),
        state: 'published',
      }

      content = [{ "title" => "title_one", "base_path" => "base_path_one", "description" => "description_one" }]
      stub_publishing_api_has_content(content, params)

      suggestion = { "taxon_content_id" => topic_content_id, "explanation" => %i(word) }
      suggested_topic = SuggestTopicsService::SuggestedTopic.new(suggestion, 0)
      expect(suggested_topic.content).to eq( [{ link: { description: "description_one", path: "base_path_one", text: "title_one" } }] )
    end
  end
end
