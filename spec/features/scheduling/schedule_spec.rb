# frozen_string_literal: true

RSpec.feature "Schedule an edition" do
  include ActiveJob::TestHelper

  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  scenario do
    given_there_is_an_edition_ready_to_schedule
    when_i_visit_the_summary_page
    and_i_click_schedule
    and_i_select_the_reviewed_option
    then_i_see_the_edition_has_been_scheduled
    and_i_can_no_longer_edit_the_content
  end

  def given_there_is_an_edition_ready_to_schedule
    @datetime = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition, scheduled_publishing_datetime: @datetime)
    @request = stub_default_publishing_api_put_intent
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_schedule
    click_on "Schedule"
  end

  def and_i_select_the_reviewed_option
    choose I18n.t!("schedule.new.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_has_been_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))
    expect(enqueued_jobs.count).to eq 1

    job = enqueued_jobs.first
    expect(job[:args].first).to eq @edition.id
    expect(job[:at].to_i).to eq @datetime.to_i

    assert_requested @request

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))

    scheduled_date = @datetime.strftime("%-d %B %Y")
    expect(page).to have_content("Scheduled to publish at 10:00am on #{scheduled_date}")
  end

  def and_i_can_no_longer_edit_the_content
    expect(page).not_to have_link("Change Content")
  end
end
