# frozen_string_literal: true

RSpec.feature "Schedule an edition" do
  include ActiveJob::TestHelper

  scenario do
    given_there_is_an_edition_ready_to_schedule
    when_i_visit_the_summary_page
    and_i_schedule_a_document
    then_i_see_the_edition_has_been_scheduled
    and_i_can_no_longer_edit_the_content
  end

  def given_there_is_an_edition_ready_to_schedule
    @datetime = Time.current.tomorrow
    @edition = create(:edition, scheduled_publishing_datetime: @datetime)
    @request = stub_default_publishing_api_put_intent
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_schedule_a_document
    click_on "Schedule"
    choose I18n.t!("schedule.confirmation.review_status.reviewed")
    click_on "Publish"
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
  end

  def and_i_can_no_longer_edit_the_content
    expect(page).not_to have_link("Change Content")
  end
end
