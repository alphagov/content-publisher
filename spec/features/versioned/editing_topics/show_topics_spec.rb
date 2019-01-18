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
    document_type = build(:document_type, topics: true)
    @document = create(:versioned_document,
                       :with_current_edition,
                       document_type_id: document_type.id)
  end

  def when_the_document_has_no_topics
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {},
    )
  end

  def and_i_visit_the_document_page
    visit versioned_document_path(@document)
  end

  def then_i_see_there_are_no_topics
    expect(page).to have_content(I18n.t!("documents.show.topics.no_topics"))
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
    within("#topics") do
      expect(page).to have_content("Level One Topic")
      expect(page).to have_content("Level Two Topic")
      expect(page).to have_content("Level Three Topic")
    end
  end
end
