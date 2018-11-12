# frozen_string_literal: true

RSpec.feature "Save topics when the Publishing API is down" do
  include TopicsHelper

  scenario do
    given_there_is_a_document
    and_i_am_on_the_topics_page
    and_the_publishing_api_is_down
    when_i_click_the_save_button
    then_i_see_the_document_page
    and_the_topic_update_failed
  end

  def given_there_is_a_document
    @document = create :document
  end

  def and_i_am_on_the_topics_page
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {
        "taxons" => %w(level_one_topic),
      },
    )

    publishing_api_has_taxonomy
    visit document_topics_path(@document)
  end

  def and_the_publishing_api_is_down
    stub_publishing_api_patch_links(@document.content_id, {})
    publishing_api_isnt_available
  end

  def when_i_click_the_save_button
    click_on "Save"
  end

  def then_i_see_the_document_page
    expect(current_path).to eq document_path(@document)
  end

  def and_the_topic_update_failed
    expect(page).to have_content(I18n.t!("documents.show.flashes.topic_update_error.title"))
  end
end
