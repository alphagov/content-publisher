# frozen_string_literal: true

RSpec.feature "Edit topics when there is a conflict" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_topics_page
    given_the_remote_has_changed
    when_i_click_save
    then_i_see_an_error_message
  end

  def given_there_is_a_document
    @document = create :document
  end

  def when_i_visit_the_topics_page
    publishing_api_has_links(
      "content_id" => @document.content_id,
      "links" => {
        "taxons" => [],
      },
      "version" => 3,
    )

    # GOV.UK homepage
    publishing_api_has_expanded_links(
      "content_id" => "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a",
      "expanded_links" => {
        "level_one_taxons" => [],
      },
    )

    visit document_topics_path(Document.last)
  end

  def given_the_remote_has_changed
    #TODO: This should be moved to the gds-api-adapters
    endpoint = GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT
    stub_request(:patch, "#{endpoint}/links/#{@document.content_id}")
      .with(body: {
        "links" => {
          "taxons" => [],
        },
        "previous_version" => "3",
      })
      .to_return(status: 409)
  end

  def when_i_click_save
    click_on "Save"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t("documents.show.flashes.topic_update_conflict.title"))
  end
end
