# frozen_string_literal: true

RSpec.feature "Set scheduled publishing datetime and schedule" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_choose_a_scheduled_date_and_time
    and_i_select_schedule_to_publish
    and_i_select_a_review_option
    then_i_see_the_edition_has_been_scheduled
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule
    click_on "Schedule"
  end

  def and_i_choose_a_scheduled_date_and_time
    @date = Time.zone.now.advance(days: 2)
    fill_in "schedule[day]", with: @date.day
    fill_in "schedule[month]", with: @date.month
    fill_in "schedule[year]", with: @date.year
    select "11:00pm", from: "schedule[time]"
  end

  def and_i_select_schedule_to_publish
    choose "Schedule to publish"
    click_on "Continue"
  end

  def and_i_select_a_review_option
    stub_default_publishing_api_put_intent
    choose I18n.t!("schedule.confirmation.review_status.reviewed")
    click_on "Schedule"
  end

  def then_i_see_the_edition_has_been_scheduled
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.scheduled.name"))

    scheduled_date = @date.strftime("%-d %B %Y")
    expect(page).to have_content("Scheduled to publish at 11:00pm on #{scheduled_date}")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.scheduled")
    end
  end
end
