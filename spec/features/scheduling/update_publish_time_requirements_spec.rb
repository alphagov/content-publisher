# frozen_string_literal: true

RSpec.feature "Update publish time with requirements issues" do
  scenario "invalid date/time" do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_i_click_on_change_date
    and_i_enter_an_invalid_date
    then_i_see_an_error_to_fix_the_input
  end

  scenario "scheduling issues" do
    given_there_is_a_scheduled_edition
    when_i_visit_the_summary_page
    and_i_click_on_change_date
    and_i_enter_an_unschedulable_date
    then_i_see_an_error_to_change_the_date
  end

  def given_there_is_a_scheduled_edition
    @edition = create(:edition, :scheduled)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_change_date
    click_on "Change date"
  end

  def and_i_enter_an_invalid_date
    fill_in "schedule[date][day]", with: ""
    click_on "Save date"
  end

  def and_i_enter_an_unschedulable_date
    date = Date.yesterday
    fill_in "schedule[date][day]", with: date.day
    fill_in "schedule[date][month]", with: date.month
    fill_in "schedule[date][year]", with: date.year
    fill_in "schedule[time]", with: "11:00pm"
    click_on "Save date"
  end

  def then_i_see_an_error_to_change_the_date
    expect(page).to have_content(
      I18n.t!("requirements.schedule_date.in_the_past.form_message"),
    )
  end

  def then_i_see_an_error_to_fix_the_input
    expect(page).to have_content(
      I18n.t!("requirements.schedule_date.invalid.form_message"),
    )
  end
end
