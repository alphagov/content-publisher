# frozen_string_literal: true

RSpec.feature "Schedule to publish" do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    Sidekiq::Testing.fake! do
      travel_to(Time.zone.parse("2019-06-13 11:00")) { example.run }
    end
  end

  scenario do
    given_there_is_a_schedulable_edition

    when_i_go_to_the_summary_page
    then_i_can_edit_the_edition

    when_i_go_to_schedule_the_edition
    and_i_submit_a_review_option
    then_i_see_the_edition_is_scheduled
    and_i_can_no_longer_edit_the_edition
    and_a_new_job_is_queued
    and_a_publish_intent_is_created
  end

  def given_there_is_a_schedulable_edition
    @publish_time = Time.zone.parse("2019-06-14 9:00")
    @edition = create(:edition,
                      :publishable,
                      :schedulable,
                      proposed_publish_time: @publish_time)
  end

  def when_i_go_to_the_summary_page
    visit document_path(@edition.document)
  end

  def when_i_go_to_schedule_the_edition
    click_on "Schedule"
  end

  def then_i_can_edit_the_edition
    expect(page).to have_link("Edit Content")
  end

  def and_i_submit_a_review_option
    @request = stub_default_publishing_api_put_intent.with(
      body: hash_including(publish_time: @publish_time),
    )

    choose I18n.t!("schedule.new.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_is_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.scheduled"))

    expect(page).to have_content("Scheduled to publish at 9:00am on 14 June 2019")
  end

  def and_i_can_no_longer_edit_the_edition
    expect(page).not_to have_link("Edit Content")
  end

  def and_a_new_job_is_queued
    job = enqueued_jobs.first
    expect(job[:args].first).to eq @edition.id
    expect(job[:at].to_i).to eq @publish_time.to_i
  end

  def and_a_publish_intent_is_created
    expect(@request).to have_been_requested
  end
end
