# frozen_string_literal: true

RSpec.feature "Unschedule a document when Publishing API is down" do
  scenario do
    given_there_is_a_scheduled_document
    and_the_publishing_api_is_down
    when_i_visit_the_summary_page
    and_i_click_stop_scheduled_publishing
    then_i_see_an_error_message
    and_the_document_is_still_scheduled
  end

  def given_there_is_a_scheduled_document
    schedule = create(:scheduling, reviewed: true)
    @edition = create(:edition,
                      :scheduled,
                      scheduling: schedule,
                      scheduled_publishing_datetime: Time.zone.now)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_stop_scheduled_publishing
    click_on "Stop scheduled publishing"
  end

  def then_i_see_an_error_message
    expect(page).to have_content(I18n.t!("documents.show.flashes.unschedule_error.title"))
  end

  def and_the_document_is_still_scheduled
    expect(page).to have_content("Scheduled to publish")
  end
end
