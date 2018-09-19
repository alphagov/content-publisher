# frozen_string_literal: true

RSpec.feature "Publishing a document when Asset Manager is down" do
  scenario "User publishes a document with a lead image" do
    given_there_is_a_document_with_a_lead_image
    and_asset_manager_is_down
    when_i_try_to_publish_the_document
    then_i_see_the_publish_failed

    given_the_api_is_up_again_and_i_try_to_publish_the_document
    then_i_see_the_publish_succeeded
  end

  def given_there_is_a_document_with_a_lead_image
    @image = create(:image, :in_asset_manager)
    document = create(:document, publication_state: "sent_to_draft", lead_image: @image)
    @image.update(document: document)
  end

  def and_asset_manager_is_down
    #TODO: Add stub to gds-api-adapters test helpers
    stub_request(:put, "https://asset-manager.test.gov.uk/assets/#{@image.asset_manager_id}").to_return(status: 500)
    stub_any_publishing_api_publish
  end

  def when_i_try_to_publish_the_document
    visit document_path(Document.last)
    click_on "Publish"
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_failed
    expect(page).to have_content(I18n.t("documents.show.flashes.publish_error.title"))
  end

  def given_the_api_is_up_again_and_i_try_to_publish_the_document
    @request = stub_request(:put, "https://asset-manager.test.gov.uk/assets/#{@image.asset_manager_id}")
    visit document_path(Document.last)
    click_on "Retry publishing"
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@request).to have_been_requested.twice
    expect(page).to have_content(I18n.t("publish_document.published.reviewed.title"))
  end
end
