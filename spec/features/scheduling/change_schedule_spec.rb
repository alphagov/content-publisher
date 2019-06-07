# frozen_string_literal: true

RSpec.feature "Change schedule" do
  include ActiveJob::TestHelper

  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  scenario do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_i_click_on_change_date
    and_i_set_a_new_schedule_datetime
    then_i_see_the_edition_is_rescheduled
    and_the_edition_is_scheduled_to_publish
  end

  def given_there_is_a_scheduled_edition
    datetime = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition, :scheduled, scheduled_publishing_datetime: datetime)
    @request = stub_default_publishing_api_put_intent
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_change_date
    click_on "Change date"
  end

  def and_i_set_a_new_schedule_datetime
    @new_datetime = Time.current.advance(days: 2).change(hour: 23)
    fill_in "schedule[date][day]", with: @new_datetime.day
    fill_in "schedule[date][month]", with: @new_datetime.month
    fill_in "schedule[date][year]", with: @new_datetime.year
    select "11:00pm", from: "schedule[time]"
    click_on "Save date"
  end

  def then_i_see_the_edition_is_rescheduled
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.schedule_updated"))

    expect(page).to have_content(I18n.t!("documents.show.scheduling.notice.scheduled",
                                         time: "11:00pm",
                                         date: @new_datetime.strftime("%-d %B %Y")))
  end

  def and_the_edition_is_scheduled_to_publish
    expect(enqueued_jobs.count).to eq 1
    expect(enqueued_jobs.first[:args].first).to eq @edition.id
    expect(enqueued_jobs.first[:at].to_i).to eq @new_datetime.to_i
    expect(@request).to have_been_requested
  end
end
