RSpec.feature "Scheduled publishing" do
  around do |example|
    travel_to(Time.zone.parse("2019-06-21")) { example.run }
  end

  scenario do
    given_there_is_a_schedulable_edition
    when_i_go_to_schedule_a_publishing
    and_i_submit_the_reviewed_option
    then_i_see_the_edition_is_scheduled
    and_a_publish_intent_is_created
    and_there_is_a_scheduled_timeline_entry

    when_the_publishing_job_runs
    then_the_edition_is_published
    and_the_editors_are_notified

    when_i_visit_the_summary_page
    then_i_can_see_the_publishing_succeeded
    and_there_is_a_scheduled_publishing_timeline_entry
  end

  def given_there_is_a_schedulable_edition
    @edition = create(:edition,
                      :schedulable,
                      created_by: current_user,
                      proposed_publish_time: Time.zone.parse("2019-06-22 9:00"),
                      base_path: "/news/breaking-story")
  end

  def when_i_go_to_schedule_a_publishing
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_i_submit_the_reviewed_option
    @publish_intent_request = stub_any_publishing_api_put_intent.with(
      body: hash_including(publish_time: @edition.proposed_publish_time),
    )
    choose I18n.t!("schedule.new.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_is_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))
    visit document_path(@edition.document)

    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))
    expect(page).to have_content("Scheduled to publish at 9:00am on 22 June 2019")
  end

  def and_there_is_a_scheduled_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.scheduled"))
  end

  def and_a_publish_intent_is_created
    expect(@publish_intent_request).to have_been_requested
  end

  def when_the_publishing_job_runs
    travel_to(Time.zone.parse("2019-6-22 9:00"))
    populate_default_government_bulk_data
    stub_any_publishing_api_put_content
    @publish_request = stub_publishing_api_publish(@edition.content_id,
                                                   update_type: nil,
                                                   locale: @edition.locale)
    Sidekiq::Worker.drain_all
  end

  def then_the_edition_is_published
    expect(@publish_request).to have_been_requested
  end

  def and_the_editors_are_notified
    message = ActionMailer::Base.deliveries.first
    expected_subject = I18n.t("scheduled_publish_mailer.success_email.subject.published",
                              title: @edition.title)

    expect(message.to).to include(current_user.email)
    expect(message.subject).to eq(expected_subject)

    expect(message.body).to have_content("https://www.test.gov.uk/news/breaking-story")
    expect(message.body)
      .to have_content(I18n.t("scheduled_publish_mailer.success_email.details.publish",
                              time: "9:00am",
                              date: "22 June 2019"))
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_can_see_the_publishing_succeeded
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
  end

  def and_there_is_a_scheduled_publishing_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.scheduled_publishing_succeeded"))
  end
end
