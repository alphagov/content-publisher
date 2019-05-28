# frozen_string_literal: true

RSpec.feature "Schedule a document when Publishing API is down" do
  scenario do
    given_there_is_an_edition_ready_to_schedule
    and_the_publishing_api_is_down
    when_i_visit_the_summary_page
    and_i_try_to_schedule_the_edition
    then_i_see_an_error_message
    and_the_document_has_not_been_scheduled
  end

  def given_there_is_an_edition_ready_to_schedule
    @datetime = Time.current.tomorrow
    @edition = create(:edition, scheduled_publishing_datetime: @datetime)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_try_to_schedule_the_edition
    click_on "Schedule"
    choose I18n.t!("schedule.confirmation.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("documents.show.flashes.schedule_error.title"))
  end

  def and_the_document_has_not_been_scheduled
    @edition.reload
    expect(@edition.state).to_not eq("scheduled")
  end
end
