# frozen_string_literal: true

RSpec.feature "Scheduled publishing without review" do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    Sidekiq::Testing.fake! do
      travel_to(Time.zone.parse("2019-06-20"))
      example.run
      travel_back
    end
  end

  scenario do
    given_there_is_a_schedulable_edition
    when_i_go_to_schedule_a_publishing
    and_i_submit_the_not_reviewed_option
    then_i_see_the_edition_is_scheduled

    when_the_publishing_job_runs
    then_the_edition_is_published
    and_the_editors_are_notified

    when_i_visit_the_summary_page
    then_i_can_see_the_publishing_succeeded
    and_there_is_a_history_entry
  end

  def given_there_is_a_schedulable_edition
    @edition = create(:edition,
                      :schedulable,
                      created_by: current_user,
                      proposed_publish_time: Time.zone.parse("2019-8-10 12:00"))
  end

  def when_i_go_to_schedule_a_publishing
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_i_submit_the_not_reviewed_option
    stub_default_publishing_api_put_intent
    choose I18n.t!("schedule.new.review_status.not_reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_is_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))
  end

  def when_the_publishing_job_runs
    travel_to(Time.zone.parse("2019-8-10 12:00"))
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
    expected_subject = I18n.t("scheduled_publish_mailer.success_email.subject.published_but_needs_2i",
                              title: @edition.title)

    expect(message.to).to include(current_user.email)
    expect(message.subject).to eq(expected_subject)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_can_see_the_publishing_succeeded
    expect(page).to have_content(I18n.t!("user_facing_states.published_but_needs_2i.name"))
  end

  def and_there_is_a_history_entry
    expect(page).to have_content(
      I18n.t!("documents.history.entry_types.scheduled_publishing_without_review_succeeded"),
    )
  end
end
