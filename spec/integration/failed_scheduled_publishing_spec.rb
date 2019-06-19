# frozen_string_literal: true

RSpec.describe "Failed scheduled publishing" do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.parse("2019-06-18 17:30")) { example.run }
  end

  scenario do
    given_there_is_a_scheduled_edition
    and_the_publishing_api_is_down
    when_the_scheduled_publishing_job_runs
    then_the_edition_is_set_to_failed_to_publish
    and_the_editors_are_sent_a_failure_notification
  end

  def given_there_is_a_scheduled_edition
    @edition = create(:edition,
                      :scheduled,
                      publish_time: Time.zone.parse("2019-06-18 17:00"),
                      created_by: create(:user, email: "user@example.com"),
                      base_path: "/news/breaking-story")
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_the_scheduled_publishing_job_runs
    perform_enqueued_jobs { ScheduledPublishingJob.perform_later(@edition.id) }
  end

  def then_the_edition_is_set_to_failed_to_publish
    expect(@edition.reload).to be_failed_to_publish
  end

  def and_the_editors_are_sent_a_failure_notification
    message = ActionMailer::Base.deliveries.first
    expected_subject = I18n.t("scheduled_publish_mailer.failure_email.subject",
                              title: @edition.title)

    expect(message.to).to include("user@example.com")
    expect(message.subject).to eq(expected_subject)

    expect(message.body)
      .to include(I18n.t("scheduled_publish_mailer.failure_email.schedule_date",
                         time: "5:00pm",
                         date: "18 June 2019"))
  end
end
