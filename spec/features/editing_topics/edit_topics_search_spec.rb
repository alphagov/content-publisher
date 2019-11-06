# frozen_string_literal: true

RSpec.feature "Edit topics using search", js: true do
  include TopicsHelper

  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_edit_topics
    and_i_search_the_topics
    and_i_choose_the_first_suggestion
    then_i_see_the_updated_selection
    when_i_save_the_topics
    then_i_see_the_update_succeeded
  end

  def given_there_is_an_edition
    document_type = build(:document_type, topics: true)
    @edition = create(:edition, document_type_id: document_type.id)
  end

  def when_i_visit_the_summary_page
    stub_publishing_api_has_links(
      "content_id" => @edition.content_id,
      "links" => {
        "taxons" => [],
      },
      "version" => 3,
    )

    stub_publishing_api_has_taxonomy
    visit document_path(@edition.document)
  end

  def and_i_click_on_edit_topics
    click_on "Change Topics"
  end

  def and_i_search_the_topics
    fill_in "topics-autocomplete", with: "Two"
  end

  def then_i_see_the_suggestions
    expect(find(".autocomplete__menu")).to have_content("Level Two Topic")
  end

  def and_i_choose_the_first_suggestion
    within(".autocomplete__menu") do
      find("li", text: "Level Two Topic").click
    end
  end

  def then_i_see_the_updated_selection
    expect(find("miller-columns")).to have_content("Level Two Topic")
    page.has_field?("topic-level_two_topic", checked: true, visible: true)
  end

  def when_i_save_the_topics
    @request = stub_publishing_api_patch_links(
      @edition.content_id,
      "links" => {
        "taxons" => %w(level_two_topic),
        "topics" => %w(specialist_sector_1 specialist_sector_2),
      },
      "previous_version" => 3,
    )

    click_on "Save"
  end

  def then_i_see_the_update_succeeded
    expect(page).to have_content(I18n.t!("documents.show.flashes.topics_updated"))
    expect(@request).to have_been_requested
  end
end
