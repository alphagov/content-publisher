# frozen_string_literal: true

RSpec.describe "Publishing a scheduled edition" do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.parse("2019-06-17 10:00")) { example.run }
  end

  scenario "succesful publishing" do
    given_there_is_a_scheduled_edition
    when_the_scheduled_publishing_job_runs_successfully
    then_the_edition_is_published
    and_the_editors_are_sent_a_success_notification
  end

  scenario "failed publishing" do
    given_there_is_a_scheduled_edition
    when_the_scheduled_publishing_job_fails
    then_the_edition_is_set_to_failed_to_publish
    and_the_editors_are_sent_a_failure_notification
  end

  def given_there_is_a_scheduled_edition
    scheduling = create(:scheduling,
                        reviewed: true,
                        publish_time: Time.zone.parse("2019-06-17 9:00"))
    @edition = create(:edition,
                      :scheduled,
                      scheduling: scheduling,
                      created_by: create(:user, email: "user@example.com"),
                      base_path: "/news/breaking-story")
  end

  def when_the_scheduled_publishing_job_runs_successfully
    @request = stub_publishing_api_publish(@edition.content_id,
                                           update_type: nil,
                                           locale: @edition.locale)
    perform_enqueued_jobs { ScheduledPublishingJob.perform_later(@edition.id) }
  end

  def then_the_edition_is_published
    expect(@request).to have_been_requested
    expect(@edition.reload).to be_published
  end

  def and_the_editors_are_sent_a_success_notification
    message = ActionMailer::Base.deliveries.first
    expected_subject = I18n.t("scheduled_publish_mailer.success_email.subject.published",
                              title: @edition.title)

    expect(message.to).to include("user@example.com")
    expect(message.subject).to eq(expected_subject)

    expect(message.body).to include("https://www.test.gov.uk/news/breaking-story")
    expect(message.body)
      .to include(I18n.t("scheduled_publish_mailer.success_email.details.publish",
                         time: "10:00am",
                         date: "17 June 2019"))
  end

  def when_the_scheduled_publishing_job_fails
    allow(PublishService).to receive(:new).and_raise(RuntimeError)
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
                         time: "9:00am",
                         date: "17 June 2019"))
  end
end
