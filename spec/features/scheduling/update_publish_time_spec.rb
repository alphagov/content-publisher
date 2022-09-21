RSpec.feature "Update publish time" do
  include ActiveJob::TestHelper

  around do |example|
    travel_to(Time.zone.parse("2019-06-13")) { example.run }
  end

  scenario do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_i_click_on_change_date
    and_i_set_a_new_publish_time
    then_i_see_the_edition_is_rescheduled
    and_i_see_the_timeline_entry
    and_the_publish_intent_has_been_updated
    and_a_new_job_is_queued
  end

  def given_there_is_a_scheduled_edition
    @edition = create(:edition, :scheduled)
    @request = stub_any_publishing_api_put_intent
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_change_date
    click_on "Change date"
  end

  def and_i_set_a_new_publish_time
    @new_time = Time.zone.parse("2019-08-15 23:00")
    @put_intent_request = stub_any_publishing_api_put_intent.with(
      body: hash_including(publish_time: @new_time),
    )

    fill_in "schedule[date][day]", with: "15"
    fill_in "schedule[date][month]", with: "8"
    fill_in "schedule[date][year]", with: "2019"
    fill_in "schedule[time]", with: "11:00pm"

    click_on "Save date"
  end

  def then_i_see_the_edition_is_rescheduled
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))
    expect(page).to have_content(I18n.t!("documents.show.scheduled_notice.title",
                                         datetime: @new_time.to_fs(:time_on_date)))
  end

  def and_i_see_the_timeline_entry
    click_on "Document history"
    expect(page).to have_content(I18n.t!("documents.history.entry_types.schedule_updated"))
  end

  def and_the_publish_intent_has_been_updated
    expect(@put_intent_request).to have_been_requested
  end

  def and_a_new_job_is_queued
    expect(enqueued_jobs.count).to eq 1
    expect(enqueued_jobs.first[:args].first).to eq @edition.id
    expect(enqueued_jobs.first[:at].to_i).to eq @new_time.to_i
  end
end
