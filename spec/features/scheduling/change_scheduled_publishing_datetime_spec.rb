# frozen_string_literal: true

RSpec.feature "Change scheduled publishing datetime" do
  scenario do
    given_there_is_an_edition_with_a_scheduled_publishing_datetime
    when_i_visit_the_summary_page
    and_i_click_on_change_date
    then_i_see_the_current_date_and_time_selected

    when_i_choose_a_new_scheduled_date_and_time
    and_i_click_save_date
    then_i_see_the_new_scheduled_date_and_time
  end

  def given_there_is_an_edition_with_a_scheduled_publishing_datetime
    @current_datetime = Time.current.tomorrow.change(hour: 10)
    @edition = create(:edition, scheduled_publishing_datetime: @current_datetime)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_change_date
    click_on "Change date"
  end

  def then_i_see_the_current_date_and_time_selected
    expect(page).to have_selector(
      "[@name='schedule[date][day]'][@value='#{@current_datetime.day}']",
    )
    expect(page).to have_selector(
      "[@name='schedule[date][month]'][@value='#{@current_datetime.month}']",
    )
    expect(page).to have_selector(
      "[@name='schedule[date][year]'][@value='#{@current_datetime.year}']",
    )
    expect(page).to have_field(
      "schedule[time]", text: "10:00am"
    )
  end

  def when_i_choose_a_new_scheduled_date_and_time
    @new_date = Time.current.advance(days: 2)
    fill_in "schedule[date][day]", with: @new_date.day
    fill_in "schedule[date][month]", with: @new_date.month
    fill_in "schedule[date][year]", with: @new_date.year
    select "11:00pm", from: "schedule[time]"
  end

  def and_i_click_save_date
    click_on "Save date"
  end

  def then_i_see_the_new_scheduled_date_and_time
    date = @new_date.strftime("%-d %B %Y")
    expect(page).to have_content("Proposed to publish at 11:00pm on #{date}")
  end
end
