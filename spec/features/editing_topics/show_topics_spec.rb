# frozen_string_literal: true

RSpec.feature "Show the topics for a document" do
  include TopicsHelper

  scenario do
    given_there_is_a_document
    when_the_document_has_no_topics
    and_i_visit_the_document_page
    then_i_see_there_are_no_topics

    when_the_document_has_a_topic
    and_i_visit_the_document_page
    then_i_see_the_topic_breadcrumb
  end

  def given_there_is_a_document
    document_type_schema = build(:document_type_schema, topics: true)
    @document = create(:document, document_type: document_type_schema.id)
  end

  def when_the_document_has_no_topics
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {},
    )
  end

  def and_i_visit_the_document_page
    visit document_path(Document.last)
  end

  def then_i_see_there_are_no_topics
    expect(page).to have_content(I18n.t("documents.show.topics.no_topics"))
  end

  def when_the_document_has_a_topic
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {
        "taxons" => %w(level_three_topic),
      },
    )

    publishing_api_has_taxonomy
  end

  def then_i_see_the_topic_breadcrumb
    within("#topics .topic-breadcrumb") do
      expect(page).to have_content("Level One Topic")
      expect(page).to have_content("Level Two Topic")
      expect(page).to have_content("Level Three Topic")
    end
  end
end
