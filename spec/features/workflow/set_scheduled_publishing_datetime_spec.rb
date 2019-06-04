# frozen_string_literal: true

RSpec.feature "Set scheduled publishing datetime" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule
    then_i_see_a_default_date_and_time_selected

    when_i_choose_a_scheduled_date_and_time
    and_i_select_save_proposed_date_and_time
    and_i_click_continue
    then_i_see_the_edition_has_a_proposed_scheduled_publishing_date_and_time
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

  def then_i_see_a_default_date_and_time_selected
    default_date = Time.zone.tomorrow
    expect(page).to have_selector(
      "[@name='schedule[day]'][@value='#{default_date.day}']",
    )
    expect(page).to have_selector(
      "[@name='schedule[month]'][@value='#{default_date.month}']",
    )
    expect(page).to have_selector(
      "[@name='schedule[year]'][@value='#{default_date.year}']",
    )
    expect(page).to have_field(
      "schedule[time]", text: "9:00am"
    )
  end

  def when_i_choose_a_scheduled_date_and_time
    @date = Time.zone.now.advance(days: 2)
    fill_in "schedule[day]", with: @date.day
    fill_in "schedule[month]", with: @date.month
    fill_in "schedule[year]", with: @date.year
    select "11:00pm", from: "schedule[time]"
  end

  def and_i_select_save_proposed_date_and_time
    choose "Save proposed date and time"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_the_edition_has_a_proposed_scheduled_publishing_date_and_time
    scheduled_date = @date.strftime("%-d %B %Y")
    expect(page).to have_content("Proposed to publish at 11:00pm on #{scheduled_date}")
    expect(page).to have_link("Change date")
  end
end
