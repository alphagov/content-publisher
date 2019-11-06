# frozen_string_literal: true

RSpec.feature "Scheduled publishing failed" do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    Sidekiq::Testing.fake! do
      travel_to(Time.zone.parse("2019-06-19"))
      example.run
      travel_back
    end
  end

  scenario do
    given_there_is_a_schedulable_edition
    when_i_go_to_schedule_a_publishing
    and_i_submit_a_review_option
    then_i_see_the_edition_is_scheduled

    when_the_publishing_api_is_down
    and_the_scheduled_publishing_job_runs
    then_the_editors_are_notified_of_a_publishing_failure

    when_i_visit_the_summary_page
    then_i_can_see_the_publishing_failed
    and_there_is_a_history_entry
    and_i_can_edit_the_edition
  end

  def given_there_is_a_schedulable_edition
    @edition = create(:edition,
                      :schedulable,
                      created_by: current_user,
                      proposed_publish_time: Time.zone.parse("2019-6-20 15:00"))
  end

  def when_i_go_to_schedule_a_publishing
    visit document_path(@edition.document)
    click_on "Schedule"
  end

  def and_i_submit_a_review_option
    stub_default_publishing_api_put_intent
    choose I18n.t!("schedule.new.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_is_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))
  end

  def when_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def and_the_scheduled_publishing_job_runs
    travel_to(Time.zone.parse("2019-6-20 15:00"))
    Sidekiq::Worker.drain_all
  end

  def then_the_editors_are_notified_of_a_publishing_failure
    message = ActionMailer::Base.deliveries.first
    expected_subject = I18n.t("scheduled_publish_mailer.failure_email.subject",
                              title: @edition.title)

    expect(message.to).to include(current_user.email)
    expect(message.subject).to eq(expected_subject)

    expect(message.body)
      .to include(I18n.t("scheduled_publish_mailer.failure_email.schedule_date",
                         time: "3:00pm",
                         date: "20 June 2019"))
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_can_see_the_publishing_failed
    expect(page).to have_content(I18n.t!("user_facing_states.failed_to_publish.name"))
    within(".app-c-inset-prompt") do
      expect(page).to have_content(I18n.t!("documents.show.failed_to_publish.title"))
    end
  end

  def and_there_is_a_history_entry
    expect(page).to have_content(
      I18n.t!("documents.history.entry_types.scheduled_publishing_failed"),
    )
  end

  def and_i_can_edit_the_edition
    expect(page).to have_content("Change Content")
  end
end
