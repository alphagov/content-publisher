# frozen_string_literal: true

RSpec.feature "Clear scheduled publishing datetime" do
  scenario do
    given_there_is_an_edition_with_a_set_scheduled_publishing_datetime
    when_i_visit_the_summary_page
    and_i_click_on_publish_date
    then_i_see_the_existing_scheduled_publishing_date_and_time
    when_i_click_clear_date
    then_i_see_the_default_scheduled_publishing_date_and_time
  end

  def given_there_is_an_edition_with_a_set_scheduled_publishing_datetime
    @datetime = Time.zone.now.advance(days: 2).midday
    @edition = create(:edition, scheduled_publishing_datetime: @datetime)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_publish_date
    scheduled_date = @datetime.strftime("%-d %B %Y - 12:00pm")
    find(".govuk-details__summary-text", text: "Publish date: #{scheduled_date}").click
  end

  def then_i_see_the_existing_scheduled_publishing_date_and_time
    expect(page).to have_selector(
      "[@name='scheduled[day]'][@value='#{@datetime.day}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[month]'][@value='#{@datetime.month}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[year]'][@value='#{@datetime.year}']",
    )
    expect(page).to have_select("scheduled[time]", selected: "12:00pm")
  end

  def when_i_click_clear_date
    click_on "Clear date"
  end

  def then_i_see_the_default_scheduled_publishing_date_and_time
    default_date = Time.zone.tomorrow

    expect(page).to have_content("Schedule publishing")
    expect(page).to have_selector(
      "[@name='scheduled[day]'][@value='#{default_date.day}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[month]'][@value='#{default_date.month}']",
    )
    expect(page).to have_selector(
      "[@name='scheduled[year]'][@value='#{default_date.year}']",
    )
    expect(page).to have_select("scheduled[time]", selected: "9:00am")
  end
end
