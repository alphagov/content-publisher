RSpec.feature "Publish without review" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_publish_without_review
    then_i_see_the_publish_succeeded
    and_the_editors_receive_an_email
    and_i_see_the_published_without_review_timeline_entry

    when_i_visit_the_summary_page
    then_i_see_it_has_not_been_reviewed

    when_i_click_the_approve_button
    then_i_see_that_its_reviewed
    and_i_see_the_approved_timeline_entry
  end

  def given_there_is_an_edition
    @creator = create(:user, email: "someone@example.com")

    @edition = create(:edition,
                      :publishable,
                      created_by: @creator,
                      created_at: 1.day.ago,
                      base_path: "/news/banana-pricing-updates",
                      editors: [@creator])
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def when_i_click_the_approve_button
    travel_to(@publish_time + 1.hour) do
      click_on "Approve"
    end
  end

  def and_i_publish_without_review
    travel_to(@publish_time = Time.zone.now) do
      click_on "Publish"
      choose I18n.t!("publish.confirmation.should_be_reviewed")
      stub_any_publishing_api_put_content
      stub_any_publishing_api_publish
      click_on "Confirm publish"
    end
  end

  def then_i_see_the_publish_succeeded
    expect(page).to have_content(I18n.t!("publish.published.published_without_review.title"))
  end

  def then_i_see_it_has_not_been_reviewed
    expect(page).to have_content I18n.t!("user_facing_states.published_but_needs_2i.name")
  end

  def and_i_see_the_published_without_review_timeline_entry
    visit document_history_path(@edition.document)
    expect(page).to have_content I18n.t!("documents.history.entry_types.published_without_review")
  end

  def then_i_see_that_its_reviewed
    expect(page).to have_content(I18n.t!("documents.show.flashes.approved"))
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
  end

  def and_i_see_the_approved_timeline_entry
    click_on "Document history"
    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.approved")
    end
  end

  def and_the_editors_receive_an_email
    Sidekiq::Worker.drain_all
    tos = ActionMailer::Base.deliveries.map(&:to)
    message = ActionMailer::Base.deliveries.first

    expect(tos).to contain_exactly([@creator.email], [current_user.email])
    expect(message.body).to have_content("https://www.test.gov.uk/news/banana-pricing-updates")
    expect(message.body).to have_content(document_path(@edition.document))

    expect(message.subject).to eq(I18n.t("publish_mailer.publish_email.subject.published_but_needs_2i",
                                         title: @edition.title))

    expect(message.body).to have_content(I18n.t("publish_mailer.publish_email.details.publish",
                                                datetime: @publish_time.to_fs(:time_on_date),
                                                user: current_user.name))
  end
end
