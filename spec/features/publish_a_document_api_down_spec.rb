# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Publishing a document when the API is down" do
  scenario "User publishes a document" do
    given_there_is_a_document
    and_the_publishing_api_is_down
    when_i_try_to_publish_the_document
    then_i_see_the_publish_failed
  end

  def given_there_is_a_document
    @document = create(:document)
  end

  def and_the_publishing_api_is_down
    @request = stub_publishing_api_publish(@document.content_id, {})
    publishing_api_isnt_available
  end

  def when_i_try_to_publish_the_document
    visit document_path(@document)
    click_on I18n.t("documents.show.actions.publish")
    click_on I18n.t("publish_document.confirmation.actions.confirm")
  end

  def then_i_see_the_publish_failed
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("documents.show.flashes.publish_error"))
    expect(@document.reload.publication_state).to eq("error_sending_to_live")
  end
end
