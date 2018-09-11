# frozen_string_literal: true

RSpec.feature "Publishing a document" do
  scenario "User publishes a document" do
    given_there_is_a_document_in_draft
    when_i_visit_the_document_page
    and_i_click_on_the_publish_button
    and_i_say_that_the_document_has_been_reviewed
    and_i_confirm_the_publishing
    then_i_see_the_publish_succeeded
    and_i_see_the_content_is_in_published_state
  end

  def given_there_is_a_document_in_draft
    @document = create(:document, publication_state: "sent_to_draft")
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_the_publish_button
    click_publish_button
  end

  def and_i_say_that_the_document_has_been_reviewed
    choose I18n.t("publish_document.confirmation.has_been_reviewed")
  end

  def and_i_confirm_the_publishing
    @request = stub_publishing_api_publish(@document.content_id, update_type: nil, locale: @document.locale)
    click_confirm_publish_button
  end

  def then_i_see_the_publish_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("publish_document.published_document.reviewed.title"))
  end

  def and_i_see_the_content_is_in_published_state
    visit document_path(@document)
    expect(page).to have_content(I18n.t("user_facing_states.published.name"))
  end
end
