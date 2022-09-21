RSpec.feature "Publishing an edition" do
  scenario do
    given_there_is_an_edition_in_draft
    when_i_visit_the_summary_page
    and_i_publish_the_edition
    then_i_see_the_publish_succeeded
    and_the_content_is_shown_as_published
    and_i_see_a_link_to_the_content_data_page_for_the_document
    and_i_receive_a_confirmation_email
    and_i_see_there_is_a_timeline_entry
  end

  def given_there_is_a_major_change_to_a_live_edition
    @edition = create(:edition,
                      :publishable,
                      number: 2,
                      update_type: "major",
                      created_at: 1.day.ago,
                      change_note: "The best major change ever")
  end

  def given_there_is_a_minor_change_to_a_live_edition
    @edition = create(:edition,
                      :publishable,
                      number: 2,
                      update_type: "minor")
  end

  def given_there_is_an_edition_in_draft
    @creator = create(:user, email: "someone@example.com")

    @edition = create(:edition,
                      :publishable,
                      created_by: @creator,
                      base_path: "/news/banana-pricing-updates",
                      editors: [@creator])
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_publish_the_edition
    travel_to(@publish_time = Time.zone.now) do
      click_on "Publish"
      choose I18n.t!("publish.confirmation.has_been_reviewed")
      stub_any_publishing_api_put_content
      @content_request = stub_publishing_api_publish(@edition.content_id, update_type: nil, locale: @edition.locale)
      click_on "Confirm publish"
    end
  end

  def then_i_see_the_publish_succeeded
    expect(@content_request).to have_been_requested
    expect(page).to have_content(I18n.t!("publish.published.reviewed.title"))
  end

  def and_the_content_is_shown_as_published
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
    expect(page).to have_link("View on GOV.UK", href: "https://www.test.gov.uk/news/banana-pricing-updates")
  end

  def and_i_see_there_is_a_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.published"))
  end

  def and_i_see_a_link_to_the_content_data_page_for_the_document
    content_data_url_prefix = "https://content-data.test.gov.uk/metrics"
    expect(page).to have_link(
      "View data about this page",
      href: content_data_url_prefix + @edition.base_path,
    )
  end

  def and_i_receive_a_confirmation_email
    Sidekiq::Worker.drain_all
    tos = ActionMailer::Base.deliveries.map(&:to)
    message = ActionMailer::Base.deliveries.first

    expect(tos).to match_array [[@creator.email], [current_user.email]]
    expect(message.body).to have_content("https://www.test.gov.uk/news/banana-pricing-updates")
    expect(message.body).to have_content(document_path(@edition.document))

    expect(message.subject).to eq(I18n.t("publish_mailer.publish_email.subject.published",
                                         title: @edition.title))

    expect(message.body).to have_content(I18n.t("publish_mailer.publish_email.details.publish",
                                                datetime: @publish_time.to_fs(:time_on_date),
                                                user: current_user.name))
  end
end
