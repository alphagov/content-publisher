# frozen_string_literal: true

RSpec.feature "Show the topics for a document" do
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
    @document = create :document
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

    # GOV.UK homepage
    publishing_api_has_expanded_links(
      "content_id" => "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a",
      "expanded_links" => {
        "level_one_taxons" => [
          {
            "title" => "Level One Topic",
            "content_id" => "level_one_topic",
          },
        ],
      },
    )

    publishing_api_has_expanded_links(
      "content_id" => "level_one_topic",
      "expanded_links" => {
        "child_taxons" => [
          {
            "content_id" => "level_two_topic",
            "title" => "Level Two Topic",
            "links" => {
              "child_taxons" => [
                {
                  "content_id" => "level_three_topic",
                  "title" => "Level Three Topic",
                  "links" => {},
                },
              ],
            },
          },
        ],
      },
    )
  end

  def then_i_see_the_topic_breadcrumb
    within("#topics .topic-breadcrumb") do
      expect(page).to have_content("Level One Topic")
      expect(page).to have_content("Level Two Topic")
      expect(page).to have_content("Level Three Topic")
    end
  end
end
