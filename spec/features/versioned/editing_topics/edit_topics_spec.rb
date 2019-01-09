# frozen_string_literal: true

RSpec.feature "Edit topics for a document" do
  include TopicsHelper

  scenario do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_click_on_edit_topics
    then_i_see_the_current_selections
    when_i_edit_the_topics
    then_i_see_the_update_succeeded
  end

  def given_there_is_a_document
    document_type = build(:document_type, topics: true)
    @document = create(:versioned_document,
                       :with_current_edition,
                       document_type_id: document_type.id)
  end

  def when_i_visit_the_document_page
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {
        "taxons" => %w(level_three_topic),
      },
      "version" => 3,
    )

    publishing_api_has_taxonomy
    visit versioned_document_path(@document)
  end

  def and_i_click_on_edit_topics
    click_on "Change Topics"
  end

  def then_i_see_the_current_selections
    expect(page).to have_content("Level One Topic")
    expect(page).to have_content("Level Two Topic")
    expect(page).to have_content("Level Three Topic")
    expect(find("#topic-level_one_topic")).to_not be_checked
    expect(find("#topic-level_two_topic")).to_not be_checked
    expect(find("#topic-level_three_topic")).to be_checked
  end

  def when_i_edit_the_topics
    uncheck("Level Three Topic")
    check("Level Two Topic")
    check("Level One Topic")

    @request = stub_publishing_api_patch_links(
      @document.content_id,
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
