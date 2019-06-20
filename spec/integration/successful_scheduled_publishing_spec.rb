# frozen_string_literal: true

RSpec.describe "Successful scheduled publishing" do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.parse("2019-06-17 9:00")) { example.run }
  end

  scenario do
    given_there_is_a_scheduled_edition
    when_the_scheduled_publishing_job_runs
    then_the_edition_is_published
    and_a_timeline_entry_is_created
    and_the_editors_are_sent_a_success_notification
  end

  def given_there_is_a_scheduled_edition
    scheduling = create(:scheduling,
                        publish_time: Time.zone.parse("2019-06-17 9:00"),
                        reviewed: true)
    @edition = create(:edition,
                      :scheduled,
                      scheduling: scheduling,
                      created_by: create(:user, email: "user@example.com"),
                      base_path: "/news/breaking-story")
  end

  def when_the_scheduled_publishing_job_runs
    @request = stub_publishing_api_publish(@edition.content_id,
                                           update_type: nil,
                                           locale: @edition.locale)
    perform_enqueued_jobs { ScheduledPublishingJob.perform_later(@edition.id) }
  end

  def then_the_edition_is_published
    expect(@request).to have_been_requested
    expect(@edition.reload).to be_published
  end

  def and_a_timeline_entry_is_created
    timeline_entry = @edition.timeline_entries.last
    expect(timeline_entry.entry_type).to eq("scheduled_publishing_succeeded")
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
                         time: "9:00am",
                         date: "17 June 2019"))
  end
end
