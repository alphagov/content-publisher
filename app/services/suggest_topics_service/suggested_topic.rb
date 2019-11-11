class SuggestTopicsService::SuggestedTopic
  attr_reader :topic, :explanation

  def initialize(suggestion, index)
    @topic = Topic.find(suggestion['taxon_content_id'], topic_index)
    @explanation = suggestion['explanation']
    @index = index
  end

  def hidden?
    index >= 2
  end

  def modal_id
    "modal-suggestion-#{topic.content_id}"
  end

  def content
    @content ||= begin
      content_items = content_for_topic
      parse_content_items(content_items)
    end
  end

  private
  attr_reader :index

  def topic_index
    # We only use one kind of index for this class so
    # a class variable is appropriate
    @@topic_index ||= TopicIndex.new
  end

  def parse_content_items(content_items)
    content_items.map do |content_item|
      {
        link: {
          text: content_item['title'],
          path: content_item['base_path'],
          description: content_item['description'],
        }
      }
    end
  end

  def content_for_topic
    @content_for_topic ||= begin
      GdsApi.publishing_api_v2.get_content_items(
        {
          document_type: document_types,
          link_taxons: topic.content_id,
          per_page: 5,
          fields: %w(title description base_path),
          state: 'published',
        }
      )['results']
    end
  end

  def document_types
    # Array of as many document types as would work without
    # timing out. Ideally, if this proves popular, we'd
    # use search-api to fetch content ignoring the document type
    # as there will probably be some taxons which only has
    # content that isn't included in this list

    %w(
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
  end
end
