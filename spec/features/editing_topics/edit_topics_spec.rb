# frozen_string_literal: true

RSpec.feature "Edit topics for a document" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_click_on_edit_topics
    then_i_see_the_current_selections
    when_i_edit_the_topics
    then_i_see_the_update_succeeded
  end

  def given_there_is_a_document
    @document = create :document
  end

  def when_i_visit_the_document_page
    visit document_path(Document.last)
  end

  def and_i_click_on_edit_topics
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {
        "taxons" => %w(level_three_topic),
      },
      "version" => 3,
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

    click_on "Change Topics"
  end

  def then_i_see_the_current_selections
    expect(page).to have_content("Level One Topic")
    expect(page).to have_content("Level Two Topic")
    expect(page).to have_content("Level Three Topic")
    expect(find("#level_one_topic")).to_not be_checked
    expect(find("#level_two_topic")).to_not be_checked
    expect(find("#level_three_topic")).to be_checked
  end

  def when_i_edit_the_topics
    uncheck("level_three_topic")
    check("level_two_topic")
    check("level_one_topic")

    @request = stub_publishing_api_patch_links(
      @document.content_id,
      "links" => {
        "taxons" => %w(level_one_topic level_two_topic),
      },
      "previous_version" => "3",
    )

    click_on "Save"
  end

  def then_i_see_the_update_succeeded
    expect(page).to have_content(I18n.t("documents.show.flashes.topics_updated"))
    expect(@request).to have_been_requested
  end
end
