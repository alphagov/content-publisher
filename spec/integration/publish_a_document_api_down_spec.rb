# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Publishing a document when the API is down", type: :feature do
  scenario "User publishes a document" do
    given_there_is_a_document
    and_the_publishing_api_is_down
    when_i_try_to_publish_the_document
    then_i_see_the_publish_failed
  end

  def given_there_is_a_document
    @document = create :document
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
    expect(page).to have_content "Error publishing"
  end
end
