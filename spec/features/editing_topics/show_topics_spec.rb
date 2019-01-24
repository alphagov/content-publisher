# frozen_string_literal: true

RSpec.feature "Show topics" do
  include TopicsHelper

  scenario do
    given_there_is_an_edition
    when_the_document_has_no_topics
    and_i_visit_the_summary_page
    then_i_see_there_are_no_topics

    when_the_document_has_a_topic
    and_i_visit_the_summary_page
    then_i_see_the_topic_breadcrumb
  end

  def given_there_is_an_edition
    document_type = build(:document_type, topics: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_the_document_has_no_topics
    stub_publishing_api_has_links(
      "content_id" => @edition.content_id,
      "links" => {},
    )
  end

  def and_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_see_there_are_no_topics
    expect(page).to have_content(I18n.t!("documents.show.topics.no_topics"))
  end

  def when_the_document_has_a_topic
    stub_publishing_api_has_links(
      "content_id" => @edition.content_id,
      "links" => {
        "taxons" => %w(level_three_topic),
      },
    )

    stub_publishing_api_has_taxonomy
  end

  def then_i_see_the_topic_breadcrumb
    within("#topics") do
      expect(page).to have_content("Level One Topic")
      expect(page).to have_content("Level Two Topic")
      expect(page).to have_content("Level Three Topic")
    end
  end
end
