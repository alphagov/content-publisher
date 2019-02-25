# frozen_string_literal: true

RSpec.feature "Schedule an edition" do
  scenario do
    given_there_is_an_edition_with_set_scheduled_publishing_datetime
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_select_the_content_has_been_reviewed_option
    and_i_click_on_publish
    then_i_see_the_edition_has_been_scheduled
  end

  def given_there_is_an_edition_with_set_scheduled_publishing_datetime
    datetime = Time.zone.tomorrow
    @edition = create(:edition, scheduled_publishing_datetime: datetime)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule
    click_on "Schedule"
  end

  def and_i_select_the_content_has_been_reviewed_option
    choose I18n.t!("schedule.confirmation.review_status.reviewed")
  end

  def and_i_click_on_publish
    click_on "Publish"
  end

  def then_i_see_the_edition_has_been_scheduled
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))
  end
end
