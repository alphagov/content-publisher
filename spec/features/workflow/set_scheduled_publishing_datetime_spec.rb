# frozen_string_literal: true

RSpec.feature "Set scheduled publishing datetime" do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_click_on_schedule_publishing
    then_i_see_a_default_date_and_time_selected

    when_i_choose_a_scheduled_date_and_time
    and_i_click_save
    then_i_see_the_edition_has_a_set_scheduled_publishing_date_and_time
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_schedule_publishing
    find(".govuk-details__summary-text", text: "Schedule publishing").click
  end

  def then_i_see_a_default_date_and_time_selected
    default_date = Time.zone.tomorrow
    expect(page).to have_selector(
      "[@name='scheduled[day]'][@value='#{default_date.day}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[month]'][@value='#{default_date.month}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[year]'][@value='#{default_date.year}']",
    )
    expect(page).to have_field(
      "scheduled[time]", text: "9:00am"
    )
  end

  def when_i_choose_a_scheduled_date_and_time
    @date = Time.zone.now.advance(days: 2)
    fill_in "scheduled[day]", with: @date.day
    fill_in "scheduled[month]", with: @date.month
    fill_in "scheduled[year]", with: @date.year
    select "11:00pm", from: "scheduled[time]"
  end

  def and_i_click_save
    click_on "Save"
  end

  def then_i_see_the_edition_has_a_set_scheduled_publishing_date_and_time
    scheduled_date = @date.strftime("%-d %B %Y - 11:00pm")
    expect(page).to have_content("Publish date: #{scheduled_date}")
    expect(page).to have_selector(
      "[@name='scheduled[day]'][@value='#{@date.day}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[month]'][@value='#{@date.month}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[year]'][@value='#{@date.year}']",
    )
    expect(page).to have_field("scheduled[time]", text: "11:00am")

    within first(".app-timeline-entry") do
      expect(page).to have_content I18n.t!("documents.history.entry_types.scheduled_publishing_datetime_set")
    end
  end
end
