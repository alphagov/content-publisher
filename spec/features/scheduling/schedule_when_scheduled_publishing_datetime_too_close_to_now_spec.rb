# frozen_string_literal: true

RSpec.feature "Schedule when scheduled publishing datetime is too close to now" do
  scenario do
    given_there_is_an_edition_with_a_scheduled_publishing_date_and_time_set_too_close_to_now
    when_i_visit_the_summary_page
    then_i_cannot_see_a_schedule_link
  end

  def given_there_is_an_edition_with_a_scheduled_publishing_date_and_time_set_too_close_to_now
    datetime = Time.zone.now.advance(Edition::MINIMUM_SCHEDULING_TIME)
    @edition = create(:edition, scheduled_publishing_datetime: datetime)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def then_i_cannot_see_a_schedule_link
    expect(page).not_to have_button("Schedule")
  end
end
