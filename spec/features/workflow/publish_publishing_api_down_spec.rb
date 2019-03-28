# frozen_string_literal: true

RSpec.feature "Publishing an edition when the Publishing API is down" do
  scenario do
    given_there_is_an_edition
    and_the_publishing_api_is_down
    when_i_try_to_publish_the_edition
    then_i_see_the_publish_failed

    given_the_api_is_up_again_and_i_try_to_publish_the_edition
    then_i_see_the_publish_succeeded
  end

  def given_there_is_an_edition
    @edition = create(:edition, :publishable)
  end

  def and_the_publishing_api_is_down
    @request = stub_publishing_api_publish(@edition.content_id, {})
    publishing_api_isnt_available
  end

  def when_i_try_to_publish_the_edition
    visit document_path(@edition.document)
    click_on "Publish"
    choose I18n.t!("publish.confirmation.has_been_reviewed")
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_failed
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t!("documents.show.flashes.publish_error.title"))
  end

  def given_the_api_is_up_again_and_i_try_to_publish_the_edition
    @request = stub_publishing_api_publish(@edition.content_id, {})
    visit document_path(@edition.document)
    click_on "Publish"
    choose I18n.t!("publish.confirmation.has_been_reviewed")
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@request).to have_been_requested.twice
    expect(page).to have_content(I18n.t!("publish.published.reviewed.title"))
  end
end
