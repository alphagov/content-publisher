# frozen_string_literal: true

RSpec.feature "Show all the topics" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_try_to_change_the_topics
    then_i_see_all_of_the_topics
  end

  def given_there_is_a_document
    create :document
  end

  def when_i_visit_the_document_page
    visit document_path(Document.last)
  end

  def and_i_try_to_change_the_topics
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
            "content_id" => "level_two_content_id",
            "title" => "Level Two Topic",
            "links" => {
              "child_taxons" => [
                {
                  "content_id" => "level_three_content_id",
                  "title" => "Level Three Topic",
                  "links" => {},
                },
              ],
            },
          },
        ],
      },
    )

    click_on "Change Topics"
  end

  def then_i_see_all_of_the_topics
    expect(page).to have_content("Level One Topic")
    expect(page).to have_content("Level Two Topic")
    expect(page).to have_content("Level Three Topic")
  end
end
