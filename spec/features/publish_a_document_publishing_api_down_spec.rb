# frozen_string_literal: true

RSpec.feature "Publishing a document when the Publishing API is down" do
  scenario "User publishes a document" do
    given_there_is_a_document
    and_the_publishing_api_is_down
    when_i_try_to_publish_the_document
    then_i_see_the_publish_failed

    given_the_api_is_up_again_and_i_try_to_publish_the_document
    then_i_see_the_publish_succeeded
  end

  def given_there_is_a_document
    @document = create(:document, publication_state: "sent_to_draft")
  end

  def and_the_publishing_api_is_down
    @request = stub_publishing_api_publish(@document.content_id, {})
    publishing_api_isnt_available
  end

  def when_i_try_to_publish_the_document
    visit document_path(@document)
    click_on "Publish"
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_failed
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.publish_error.title"))
    expect(@document.reload.publication_state).to eq("error_sending_to_live")
  end

  def given_the_api_is_up_again_and_i_try_to_publish_the_document
    @request = stub_publishing_api_publish(@document.content_id, {})
    visit document_path(@document)
    click_on "Retry publishing"
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@request).to have_been_requested.twice
    expect(page).to have_content(I18n.t("publish_document.published.reviewed.title"))
  end
end
