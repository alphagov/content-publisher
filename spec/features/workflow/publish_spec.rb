# frozen_string_literal: true

RSpec.feature "Publishing an edition" do
  scenario do
    given_there_is_an_edition_in_draft
    when_i_visit_the_summary_page
    and_i_publish_the_edition
    then_i_see_the_publish_succeeded
    and_the_content_is_shown_as_published
    and_there_is_a_history_entry
  end

  def given_there_is_an_edition_in_draft
    @edition = create(:edition,
                      :publishable,
                      base_path: "/news/banana-pricing-updates")
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_publish_the_edition
    click_on "Publish"
    choose I18n.t!("publish.confirmation.has_been_reviewed")
    @content_request = stub_publishing_api_publish(@edition.content_id, update_type: nil, locale: @edition.locale)
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@content_request).to have_been_requested
    expect(page).to have_content(I18n.t!("publish.published.reviewed.title"))
  end

  def and_the_content_is_shown_as_published
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
    expect(page).to have_link("View published edition on GOV.UK", href: "https://www.test.gov.uk/news/banana-pricing-updates")
  end

  def and_there_is_a_history_entry
    expect(page).to have_content(I18n.t!("documents.history.entry_types.published"))
  end
end
