# frozen_string_literal: true

RSpec.feature "Publishing a document" do
  scenario do
    given_there_is_a_document_in_draft
    when_i_visit_the_document_page
    and_i_click_on_the_publish_button
    and_i_say_that_the_document_has_been_reviewed
    and_i_confirm_the_publishing
    then_i_see_the_publish_succeeded
    and_i_see_the_content_is_in_published_state
    and_i_see_the_view_on_govuk_link
    and_there_is_a_history_entry
  end

  def given_there_is_a_document_in_draft
    @document = create(:document, :with_required_content_for_publishing, publication_state: "sent_to_draft", base_path: "/news/banana-pricing-updates")
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_the_publish_button
    click_on "Publish"
  end

  def and_i_say_that_the_document_has_been_reviewed
    choose I18n.t("publish_document.confirmation.has_been_reviewed")
  end

  def and_i_confirm_the_publishing
    @request = stub_publishing_api_publish(@document.content_id, update_type: nil, locale: @document.locale)
    asset_manager_update_asset(SecureRandom.uuid)
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content(I18n.t("publish_document.published.reviewed.title"))
  end

  def and_i_see_the_content_is_in_published_state
    visit document_path(@document)
    expect(page).to have_content(I18n.t("user_facing_states.published.name"))
  end

  def and_i_see_the_view_on_govuk_link
    expect(page).to have_link("View published edition on GOV.UK", href: "https://www.test.gov.uk/news/banana-pricing-updates")
  end

  def and_there_is_a_history_entry
    visit document_path(@document)
    expect(page).to have_content(I18n.t("documents.history.entry_types.published"))
  end
end
