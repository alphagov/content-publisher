# frozen_string_literal: true

RSpec.feature "Schedule an edition" do
  include ActiveJob::TestHelper

  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  scenario "draft" do
    given_there_is_an_edition_ready_to_schedule
    when_i_visit_the_summary_page
    and_i_click_schedule
    and_i_select_the_reviewed_option
    then_i_see_the_edition_is_scheduled
    and_the_edition_is_scheduled_to_publish
    and_i_can_no_longer_edit_the_content
  end

  scenario "submitted for 2i" do
    given_there_is_an_edition_ready_to_schedule
    and_the_edition_is_submitted_for_2i
    when_i_visit_the_summary_page
    and_i_click_schedule_to_publish
    and_i_select_the_reviewed_option
    then_i_see_the_edition_is_scheduled
    and_the_edition_is_scheduled_to_publish
    and_i_can_no_longer_edit_the_content
  end

  def given_there_is_an_edition_ready_to_schedule
    @datetime = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition, :publishable, scheduled_publishing_datetime: @datetime)
  end

  def and_the_edition_is_submitted_for_2i
    @edition.assign_status("submitted_for_review", current_user).save!
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_schedule
    click_on "Schedule"
  end

  def and_i_click_schedule_to_publish
    click_on "Schedule to publish"
  end

  def and_i_select_the_reviewed_option
    @request = stub_default_publishing_api_put_intent
    choose I18n.t!("schedule.new.review_status.reviewed")
    click_on "Schedule"
  end

  def and_the_edition_is_scheduled_to_publish
    expect(enqueued_jobs.count).to eq 1

    job = enqueued_jobs.first
    expect(job[:args].first).to eq @edition.id
    expect(job[:at].to_i).to eq @datetime.to_i

    expect(@request).to have_been_requested
  end

  def then_i_see_the_edition_is_scheduled
    expect(page).to have_content(I18n.t!("schedule.scheduled.title"))

    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.scheduled"))

    scheduled_date = @datetime.strftime("%-d %B %Y")
    expect(page).to have_content("Scheduled to publish at 10:00am on #{scheduled_date}")
  end

  def and_i_can_no_longer_edit_the_content
    expect(page).not_to have_link("Change Content")
  end
end
