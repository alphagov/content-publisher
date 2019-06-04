# frozen_string_literal: true

RSpec.feature "Set scheduled publishing datetime without selecting scheduling action" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    and_i_choose_a_scheduled_date_and_time
    and_i_click_continue
    then_i_see_an_error_about_not_selecting_a_scheduling_option
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
    @date = Time.current.advance(days: 2)
    fill_in "schedule[date][day]", with: @date.day
    fill_in "schedule[date][month]", with: @date.month
    fill_in "schedule[date][year]", with: @date.year
    select "11:00pm", from: "schedule[time]"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_an_error_about_not_selecting_a_scheduling_option
    expect(page).to have_content(
      I18n.t!("requirements.scheduled_datetime.action_not_selected.form_message"),
    )
  end
end
